import os
import sys
import requests
import time
from datetime import datetime
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# ==========================================
# 설정 (Configuration)
# ==========================================
# --- Configuration ---
# Source: Solr 5.3.1 (기존)
SOURCE_SOLR_URL = "http://10.0.1241/solr/test_kr"
# Target: Solr 9.x (신규)
#TARGET_SOLR_URL = "http://10.0.1191:8983/solr/test_kr"
# 타겟 노드를 리스트로 선언합니다. (실제 IP 또는 도메인으로 변경하세요)
TARGET_SOLR_URLS = [
    "http://10.0.1191:8983/solr/test_kr",
    "http://10.0.1192:8983/solr/test_kr"
]




# 누락 ID가 저장된 텍스트 파일 경로
MISSING_FILE_PATH = "missing_ids_list.txt"

# 한 번에 조회 및 이관할 ID 개수 (URL 길이 제한 및 메모리 보호용)
CHUNK_SIZE = 200 

def load_ids_from_file(filepath):
    """텍스트 파일에서 ID 리스트를 안전하게 읽어와 정제(Sanitization)합니다."""
    if not os.path.exists(filepath):
        print(f"[Error] '{filepath}' 파일을 찾을 수 없습니다. 먼저 검증 스크립트를 실행해 주세요.")
        sys.exit(1)
        
    ids = []
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            clean_id = line.strip()
            if clean_id:  # 빈 줄 무시
                ids.append(clean_id)
    return ids

def create_session():
    """안정적인 HTTP 통신을 위한 세션 생성"""
    session = requests.Session()
    retry = Retry(total=3, backoff_factor=0.5)
    adapter = HTTPAdapter(pool_connections=5, pool_maxsize=5, max_retries=retry)
    session.mount('http://', adapter)
    return session

def chunk_list(lst, n):
    """리스트를 n개씩 잘라서 반환하는 제너레이터"""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

def main():
    # 1. 파일에서 대상 ID 로드
    target_ids = load_ids_from_file(MISSING_FILE_PATH)
    
    if not target_ids:
        print(f"[Warn] '{MISSING_FILE_PATH}' 파일이 비어있거나 유효한 ID가 없습니다.")
        sys.exit(0)

    print("==================================================")
    print(f"--- 누락 데이터 파일 기반 이관 시작 (총 {len(target_ids):,} 건) ---")
    print(f"--- Source: {MISSING_FILE_PATH} ---")
    print("==================================================")

    session = create_session()
    total_migrated = 0
    node_index = 0

    # 2. ID 리스트를 CHUNK_SIZE(200개) 단위로 분할하여 처리
    for chunk_idx, id_chunk in enumerate(chunk_list(target_ids, CHUNK_SIZE)):
        
        # ID에 특수문자가 있을 수 있으므로 큰따옴표로 묶고 명시적 OR 연산자로 조인
        safe_ids = [f'"{doc_id}"' for doc_id in id_chunk]
        fq_string = f"id:({' OR '.join(safe_ids)})"
        
        # Source Solr에서 데이터 가져오기 (POST 방식 사용)
        fetch_payload = {
            "q": "*:*",
            "fq": fq_string,
            "rows": len(id_chunk),
            "wt": "json"
        }
        
        try:
            fetch_resp = session.post(f"{SOURCE_SOLR_URL}/select", data=fetch_payload, timeout=30)
            fetch_resp.raise_for_status()
            docs = fetch_resp.json().get("response", {}).get("docs", [])
            
            if not docs:
                print(f"[Warn] Chunk {chunk_idx+1}: Source에서 데이터를 찾지 못했습니다. (해당 ID들이 소스에 실존하는지 확인 필요)")
                continue

            # _version_ 필드 제거 (Solr 5.x -> 9.x 마이그레이션 필수 조건)
            cleaned_docs = [{k: v for k, v in d.items() if k != '_version_'} for d in docs]
            
            # Target Solr로 데이터 전송 (Round-Robin 로드 밸런싱)
            selected_node = TARGET_SOLR_URLS[node_index % len(TARGET_SOLR_URLS)]
            node_index += 1
            
            index_resp = session.post(
                f"{selected_node}/update/json/docs", 
                json=cleaned_docs, 
                timeout=30
            )
            index_resp.raise_for_status()
            
            total_migrated += len(cleaned_docs)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Chunk {chunk_idx+1} 완료: {len(cleaned_docs)} 건 이관 -> {selected_node}")

        except Exception as e:
            print(f"[Error] Chunk {chunk_idx+1} 처리 중 오류 발생: {e}")
            time.sleep(2) # 에러 시 잠시 대기하여 네트워크 숨통 트기

    # 3. 최종 커밋 (Target 1번 노드에만 요청해도 클러스터 전체 적용)
    print("\n--- 이관 완료. Target Solr 최종 커밋 실행 ---")
    try:
        session.get(f"{TARGET_SOLR_URLS[0]}/update?commit=true", timeout=60)
        print(f"✅ 최종 완료! 성공적으로 복구된 문서: {total_migrated:,} 건")
    except Exception as e:
        print(f"❌ 커밋 실패: {e}")

if __name__ == "__main__":
    main()
