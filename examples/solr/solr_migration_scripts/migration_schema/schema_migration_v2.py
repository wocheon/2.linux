#############################################################
# Usage : python schema_migration_v2.py schema.xml test_kr  #
#############################################################

import xml.etree.ElementTree as ET
import sys
import json
import requests

# --- CONFIG ---
SOLR_HOST = "http://10.0.1191:8983"
COLL_NAME = sys.argv[2] if len(sys.argv) > 2 else "test_kr"

# --- TYPE MAPPING ---
TYPE_MAPPING = {
    "string": "string", "boolean": "boolean",
    "int": "pint", "float": "pfloat", "long": "plong", "double": "pdouble",
    "date": "pdate", "tdate": "pdate", "binary": "binary",
    "text_general": "text_general",
    "text_kr": "text_kr",
    "location": "location",
    "alphaOnlySort": "string",
    "payloads": "string"
}

SKIP_BUILTIN = [
    "string", "boolean", "int", "float", "long", "double", "date", "tdate", "binary",
    "random", "ignored", "bbox", "currency", "point", "location", "location_rpt",
    "text_general", "text_ws", "lowercase", "text_en", "text_en_splitting",
    "text_en_splitting_tight", "text_general_rev", "descendent_path", "ancestor_path"
]

SKIP_FIELDS = ["id", "_version_", "_root_", "_text_"]

def parse_analyzer(analyzer_elem):
    if analyzer_elem is None: return None
    analyzer_json = {}
    tokenizer = analyzer_elem.find("tokenizer")
    if tokenizer is not None:
        analyzer_json["tokenizer"] = {"class": tokenizer.get("class")}
        for k, v in tokenizer.attrib.items():
            if k != "class": analyzer_json["tokenizer"][k] = v
    filters = []
    for f in analyzer_elem.findall("filter"):
        filter_def = {"class": f.get("class")}
        for k, v in f.attrib.items():
            if k != "class": filter_def[k] = v
        filters.append(filter_def)
    if filters: analyzer_json["filters"] = filters
    return analyzer_json

def execute_on_solr(payload, endpoint):
    """Solr API 호출 및 에러 핸들링 (개별 실행)"""
    url = f"{SOLR_HOST}/solr/{COLL_NAME}/schema"
    try:
        resp = requests.post(url, json=payload, headers={"Content-type": "application/json"})
        if resp.status_code == 200:
            print(f"[OK] {list(payload.keys())[0]}: {payload[list(payload.keys())[0]]['name']}")
        else:
            err_msg = resp.json().get('error', {}).get('msg', 'Unknown')
            name = payload[list(payload.keys())[0]]['name']
            if "already exists" in err_msg:
                print(f"[SKIP] {name}: 이미 존재함")
            else:
                print(f"[FAIL] {name}: {err_msg}")
    except Exception as e:
        print(f"[ERROR] Connection Failed: {e}")

def run_migration(xml_path):
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
    except Exception as e:
        print(f"XML Error: {e}")
        sys.exit(1)

    print(f"=== Starting Migration for {COLL_NAME} (Individual Mode) ===")

    # 1. FieldTypes
    for ft in root.findall(".//fieldType"):
        name = ft.get("name")
        clazz = ft.get("class")
        if name in SKIP_BUILTIN or "Trie" in clazz: continue

        ft_def = {"name": name, "class": clazz}

        # Analyzer Logic (Simplified)
        analyzer = ft.find("analyzer")
        simple_analyzer = None
        for a in ft.findall("analyzer"):
            if "type" not in a.attrib:
                simple_analyzer = a
                break

        if simple_analyzer is not None:
            ft_def["analyzer"] = parse_analyzer(simple_analyzer)
        else:
            idx_an = ft.find("analyzer[@type='index']")
            if idx_an is not None:
                ft_def["analyzer"] = parse_analyzer(idx_an)

        if name == "text_kr": # Force Nori
             ft_def["analyzer"] = {
                "tokenizer": {"class": "solr.KoreanTokenizerFactory", "decompoundMode": "discard", "outputUnknownUnigrams": "false"},
                "filters": [{"class": "solr.LowerCaseFilterFactory"}, {"class": "solr.KoreanPartOfSpeechStopFilterFactory"}, {"class": "solr.KoreanReadingFormFilterFactory"}]
            }

        # [즉시 실행]
        execute_on_solr({"add-field-type": ft_def}, "schema")

    # 2. Fields
    for field in root.findall(".//field"):
        name = field.get('name')
        old_type = field.get('type')

        if name in SKIP_FIELDS or (name.startswith("_") and name != "id"): continue

        new_type = TYPE_MAPPING.get(old_type, old_type)
        if "text" in old_type and new_type == "string": new_type = "text_general"

        f_def = {
            "name": name, "type": new_type,
            "stored": field.get('stored', 'true') == 'true',
            "indexed": field.get('indexed', 'true') == 'true',
            "multiValued": field.get('multiValued', 'false') == 'true'
        }
        if field.get('docValues') == 'true': f_def["docValues"] = True

        # [즉시 실행]
        execute_on_solr({"add-field": f_def}, "schema")

    print("\n=== Reloading Collection ===")
    requests.get(f"{SOLR_HOST}/solr/admin/collections?action=RELOAD&name={COLL_NAME}")
    print("Done.")

if __name__ == "__main__":
    run_migration(sys.argv[1])