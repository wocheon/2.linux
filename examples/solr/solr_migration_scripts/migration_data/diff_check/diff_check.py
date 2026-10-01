import os
import requests
import json
import time
from concurrent.futures import ThreadPoolExecutor

# ==========================================
# 설정 (Configuration)
# ==========================================
SOURCE_SOLR = "http://10.0.1241/solr/test_kr/select"
TARGET_SOLR = "http://10.0.1191:8983/solr/test_kr/select"

# 검증할 특정 일자
#DATE_QUERY = "tstamp:[2023-01-12T00:00:00Z TO 2023-01-12T23:59:59Z]"
DATE_QUERY = "tstamp:[2023-02-12T00:00:00Z TO 2023-02-14T00:00:00Z}"

# 최적화 파라미터
BATCH_SIZE = 50000  # 한 번에 가져올 행 수 (I/O 효율 극대화)
HTTP_TIMEOUT = 300  # 타임아웃 5분으로 상향

def check_missing_id_field(url, date_fq):
    """[Phase 1] id 필드 자체가 아예 없는(-id:*) 비정상 문서를 찾아냅니다."""
    params = {
        "q": "*:*",
        "fq": [date_fq, "-id:*"],
        "rows": 1000,          # 샘플로 최대 1000건까지만 가져옴
        "wt": "json"
    }

    try:
        resp = requests.get(url, params=params, timeout=HTTP_TIMEOUT)
        resp.raise_for_status()
        data = resp.json()

        num_found = data.get("response", {}).get("numFound", 0)
        docs = data.get("response", {}).get("docs", [])
        return num_found, docs
    except Exception as e:
        print(f"[Error] ID 누락 문서 검색 실패: {e}", flush=True)
        return 0, []

def fetch_id_set_task(url, fq, label):
    """[Phase 2] 멀티스레딩을 위한 독립적인 정상 ID 수집 함수"""
    id_set = set()
    cursor_mark = "*"
    start_time = time.time()

    # 세션 재사용으로 Handshake 비용 절감
    session = requests.Session()

    while True:
        params = {
            "q": "*:*",
            "fq": [fq, "id:*"],    # 확실하게 id가 있는 문서만 대상
            "fl": "id",
            "sort": "id asc",
            "rows": BATCH_SIZE,
            "cursorMark": cursor_mark,
            "wt": "json"
        }

        try:
            resp = session.get(url, params=params, timeout=HTTP_TIMEOUT)
            resp.raise_for_status()
            data = resp.json()

            docs = data.get("response", {}).get("docs", [])
            for doc in docs:
                id_set.add(doc["id"])

            # 진행 상황 출력
            if len(id_set) % 100000 == 0 or len(id_set) % BATCH_SIZE == 0:
                print(f"[{label}] 현재 {len(id_set):,} 건 수집 중...", flush=True)

            next_cursor = data.get("nextCursorMark")
            if cursor_mark == next_cursor or not docs:
                break
            cursor_mark = next_cursor

        except Exception as e:
            print(f"[{label} Error] 통신 실패: {e}", flush=True)
            break

    elapsed = time.time() - start_time
    print(f"[{label}] 수집 완료: {len(id_set):,} 건 (소요시간: {elapsed:.2f}초)", flush=True)
    return id_set

def main():
    print(f"🔍 검증 대상 기간: {DATE_QUERY}", flush=True)

    # ---------------------------------------------------------
    # 1단계: Source에서 id가 없는 비정상 문서 색출 (동기 처리)
    # ---------------------------------------------------------
    print("\n[Phase 1] Source Solr 내 'id 누락' 비정상 문서 탐지 중...", flush=True)
    no_id_count, no_id_docs = check_missing_id_field(SOURCE_SOLR, DATE_QUERY)

    if no_id_count > 0:
        print(f"   🚨 경고: id 필드가 없는 문서를 {no_id_count:,} 건 발견했습니다!", flush=True)
        with open("docs_without_id.json", "w", encoding="utf-8") as f:
            json.dump(no_id_docs, f, ensure_ascii=False, indent=2)
        print("   => 해당 문서들의 원본 데이터를 'docs_without_id.json'에 저장했습니다.", flush=True)
    else:
        print("   ✅ id가 누락된 문서는 없습니다 (정상).", flush=True)

    # ---------------------------------------------------------
    # 2단계: 정상 ID 간의 차집합(누락) 검증 (병렬 처리)
    # ---------------------------------------------------------
    print("\n[Phase 2] 정상 문서 간 ID 교차 검증 병렬 수집 시작...", flush=True)

    with ThreadPoolExecutor(max_workers=2) as executor:
        source_future = executor.submit(fetch_id_set_task, SOURCE_SOLR, DATE_QUERY, "Source")
        target_future = executor.submit(fetch_id_set_task, TARGET_SOLR, DATE_QUERY, "Target")

        source_ids = source_future.result()
        target_ids = target_future.result()

# ---------------------------------------------------------
    # 3단계: 결과 비교 및 파일 누적 저장 (수정된 부분)
    # ---------------------------------------------------------
    missing_ids = source_ids - target_ids
    print("\n" + "=" * 60, flush=True)
    print(f"📊 이번 검증 결과: 타겟 누락 건수 {len(missing_ids):,} 건", flush=True)

    if missing_ids:
        FILE_NAME = "missing_ids_list.txt"
        existing_ids = set()

        # 기존 파일이 존재하면 읽어서 Set에 담기 (중복 방지 목적)
        if os.path.exists(FILE_NAME):
            with open(FILE_NAME, "r", encoding="utf-8") as f:
                # 빈 줄을 무시하고 기존 ID를 Set으로 변환
                existing_ids = {line.strip() for line in f if line.strip()}

        # 기존 ID 집합과 신규 누락 ID 집합을 병합 (합집합 연산)
        combined_ids = existing_ids | missing_ids

        # 병합된 최종 리스트를 파일에 덮어쓰기 (항상 최신 누적 상태 유지)
        with open(FILE_NAME, "w", encoding="utf-8") as f:
            for mid in sorted(list(combined_ids)):
                f.write(f"{mid}\n")

        # 결과 리포팅
        new_added_count = len(combined_ids) - len(existing_ids)
        print(f"✅ 파일 누적 완료: '{FILE_NAME}'")
        print(f"   - 기존 보존 ID: {len(existing_ids):,} 건")
        print(f"   - 신규 추가 ID: {new_added_count:,} 건")
        print(f"   - 총 누적 ID  : {len(combined_ids):,} 건", flush=True)

    elif no_id_count == 0:
        print("✅ 모든 데이터가 완벽하게 일치합니다!", flush=True)

if __name__ == "__main__":
    main()
