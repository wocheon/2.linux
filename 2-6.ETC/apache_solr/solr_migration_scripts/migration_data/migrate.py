# -- USAGE ---
# 1. 연 단위 전체 이관: python migrate.py --year 2024
# 2. 월 단위 분할 이관: python migrate.py --year 2024 --month 3
# 3. 일 단위 분할 이관: python migrate.py --year 2024 --month 3 --day 15

import argparse
import requests
import time
import multiprocessing
from queue import Empty
from datetime import datetime, timedelta
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

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


# 튜닝 포인트 (타겟 부하 분산 및 안정성 최적화)
FETCH_BATCH_SIZE = 10000   # 네트워크 오버헤드를 줄이는 대용량 배치
NUM_WORKERS = 1            # 타겟 스트레스 완화를 위한 단일 워커
QUEUE_SIZE = 10            # 메모리 OOM 방지
LOG_INTERVAL = 10000       # N건마다 로그 출력 (배치 사이즈와 동일)
THROTTLE_DELAY = 0.5       # 타겟 노드 세그먼트 병합을 위한 지연 시간 (초)

def create_session(pool_size):
    """Keep-Alive 및 Connection Pooling을 적용한 세션 생성"""
    session = requests.Session()
    retry = Retry(total=3, backoff_factor=0.5)
    adapter = HTTPAdapter(pool_connections=pool_size, pool_maxsize=pool_size, max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session

def get_date_range_query(year, month=None, day=None):
    """밀리초 유실이 없는 안전한 Solr 날짜 범위 쿼리 생성"""
    if not year:
        return None 
    
    # 1. 종료일(end_date)을 1초 빼지 않고 다음 날 자정(00:00:00)으로 그대로 둡니다.
    if month and day:
        start_date = datetime(year, month, day)
        end_date = start_date + timedelta(days=1)
    elif month:
        start_date = datetime(year, month, 1)
        if month == 12:
            end_date = datetime(year + 1, 1, 1)
        else:
            end_date = datetime(year, month + 1, 1)
    else:
        start_date = datetime(year, 1, 1)
        end_date = datetime(year + 1, 1, 1)
    
    start_str = start_date.strftime("%Y-%m-%dT%H:%M:%SZ")
    end_str = end_date.strftime("%Y-%m-%dT%H:%M:%SZ")
    
    # 2. Solr 문법 적용: 시작은 대괄호 [포함], 끝은 중괄호 }미포함
    # 결과 예시: tstamp:[2023-01-12T00:00:00Z TO 2023-01-13T00:00:00Z}
    return f"tstamp:[{start_str} TO {end_str}}}"


def fetch_data_generator(source_url, batch_size, fq_query):
    """Solr 5.x에서 cursorMark로 데이터를 가져오는 제너레이터"""
    cursor_mark = "*"
    session = create_session(pool_size=1)
    base_url = f"{source_url}/select"
    
    params = {
        "q": "*:*", 
        "sort": "id asc", 
        "rows": batch_size,
        "cursorMark": cursor_mark, 
        "wt": "json"
    }
    
    if fq_query:
        params["fq"] = fq_query
        
    while True:
        try:
            params["cursorMark"] = cursor_mark
            resp = session.get(base_url, params=params, timeout=60)
            resp.raise_for_status()
            data = resp.json()
            
            docs = data.get("response", {}).get("docs", [])
            next_cursor_mark = data.get("nextCursorMark")
            
            if not docs:
                break
                
            yield docs
            
            if cursor_mark == next_cursor_mark:
                break
            cursor_mark = next_cursor_mark
            
        except Exception as e:
            current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{current_time}] [Fetcher Error] {e}", flush=True)
            time.sleep(5)

def indexer_worker(target_urls, queue):
    """큐에서 데이터를 꺼내 여러 Target 노드에 '교대(Round-Robin)'로 분산 색인하는 워커"""
    session = create_session(pool_size=10)
    session.headers.update({"Content-Type": "application/json"})
    
    # 라운드 로빈 로드 밸런싱을 위한 인덱스 변수
    node_index = 0  
    
    while True:
        try:
            batch_docs = queue.get(timeout=5)
            if batch_docs is None:
                break
        except Empty:
            continue
            
        # 전처리: Solr 5.x -> 9.x 마이그레이션 시 _version_ 제거 필수
        cleaned_docs = [{k: v for k, v in d.items() if k != '_version_'} for d in batch_docs]
        
        # 클라이언트 사이드 로드 밸런싱: 순차적(Round-Robin) 선택 적용
        selected_node = target_urls[node_index % len(target_urls)]
        update_url = f"{selected_node}/update/json/docs"
        
        # 다음번 배치를 위해 인덱스 증가
        node_index += 1
        
        try:
            resp = session.post(update_url, json=cleaned_docs, timeout=120)
            if resp.status_code != 200:
                current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                print(f"[{current_time}] [Indexer Error - {selected_node}] HTTP {resp.status_code}: {resp.text[:100]}", flush=True)
            
            # 타겟 노드 부하 완화를 위한 지연 시간
            if THROTTLE_DELAY > 0:
                time.sleep(THROTTLE_DELAY)
                
        except Exception as e:
            current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{current_time}] [Indexer Exception - {selected_node}] {e}", flush=True)

def main():
    parser = argparse.ArgumentParser(description="Solr Data Migration Tool")
    parser.add_argument("--year", type=int, help="Target Year (e.g., 2024)")
    parser.add_argument("--month", type=int, help="Target Month (1-12)")
    parser.add_argument("--day", type=int, help="Target Day (1-31)")
    args = parser.parse_args()

    fq_query = get_date_range_query(args.year, args.month, args.day)

    print("==================================================", flush=True)
    print(f"--- Migration Start: Source -> 2 Target Nodes ---", flush=True)
    print(f"Filter: {fq_query if fq_query else 'ALL (*:*)'}", flush=True)
    print(f"Workers: {NUM_WORKERS}, Batch: {FETCH_BATCH_SIZE}", flush=True)
    print("==================================================", flush=True)

    data_queue = multiprocessing.Queue(maxsize=QUEUE_SIZE)
    
    # 워커 생성 및 타겟 URL 리스트 전달
    workers = []
    for _ in range(NUM_WORKERS):
        p = multiprocessing.Process(target=indexer_worker, args=(TARGET_SOLR_URLS, data_queue))
        p.start()
        workers.append(p)
    
    start_time = time.time()
    total_fetched = 0
    last_logged_count = 0
    
    try:
        # Fetcher 실행
        for docs in fetch_data_generator(SOURCE_SOLR_URL, FETCH_BATCH_SIZE, fq_query):
            data_queue.put(docs)
            total_fetched += len(docs)
            
            # 지정된 건수마다 실시간 로그 출력
            if (total_fetched - last_logged_count) >= LOG_INTERVAL:
                elapsed = time.time() - start_time
                speed = total_fetched / elapsed if elapsed > 0 else 0
                current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                
                print(f"[{current_time}] Fetched: {total_fetched:>10,} docs | Speed: {speed:>5.0f} docs/sec", flush=True)
                last_logged_count = total_fetched
                
    except KeyboardInterrupt:
        print("\n[Stop] Interrupted by user.", flush=True)
    finally:
        # 워커 종료 신호 전송
        for _ in range(NUM_WORKERS):
            data_queue.put(None)
        
        for p in workers:
            p.join()
            
        print("\nFinal Committing to Target Solr...", flush=True)
        try:
            # 커밋은 클러스터 전체에 적용되므로 첫 번째 노드에만 전송
            requests.get(f"{TARGET_SOLR_URLS[0]}/update?commit=true", timeout=120)
        except Exception as e:
            print(f"Commit Failed: {e}", flush=True)
            
        total_time = time.time() - start_time
        final_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{final_time}] Done. Total: {total_fetched:,} docs in {total_time/3600:.2f} hours", flush=True)

if __name__ == "__main__":
    multiprocessing.freeze_support()
    main()
