import argparse
import requests
from concurrent.futures import ThreadPoolExecutor

# ==========================================
# 설정 (Configuration)
# ==========================================
SOURCE_SOLR = "http://10.0.1241/solr/test_kr/select"
TARGET_SOLR = "http://10.0.1191:8983/solr/test_kr/select"


def get_facet_counts(url, year, month=None):
    """지정된 URL에서 facet.range 결과를 가져와 날짜:건수 Dictionary로 반환"""
    
    if month:
        start_date = f"{year}-{month:02d}-01T00:00:00Z"
        # +1MONTH, -1DAY 로직 등은 Solr의 Date Math 연산으로 서버에 위임 가능
        end_date = f"{year}-{month:02d}-01T00:00:00Z+1MONTH"
        gap = "+1DAY"
    else:
        start_date = f"{year}-01-01T00:00:00Z"
        end_date = f"{year+1}-01-01T00:00:00Z"
        gap = "+1MONTH"

    params = {
        "q": "*:*",
        "rows": 0,
        "facet": "true",
        "facet.range": "tstamp",
        "facet.range.start": start_date,
        "facet.range.end": end_date,
        "facet.range.gap": gap,
        "wt": "json"
    }

    try:
        resp = requests.get(url, params=params, timeout=30)
        resp.raise_for_status()
        
        # Facet List (["2022-08-01T...", 100, "2022-08-02T...", 200]) 파싱
        counts_list = resp.json()['facet_counts']['facet_ranges']['tstamp']['counts']
        
        # 리스트를 { "2022-08-01": 100, "2022-08-02": 200 } 형태의 Dict로 변환
        result_dict = {}
        for i in range(0, len(counts_list), 2):
            date_clean = counts_list[i].split("T")[0] # 시간(T) 뒷부분 제거
            count = counts_list[i+1]
            if count > 0: # 0건인 날짜는 제외
                result_dict[date_clean] = count
                
        return result_dict
    except Exception as e:
        print(f"[Error] {url} 통신 실패: {e}")
        return {}

def main():
    parser = argparse.ArgumentParser(description="Solr Source vs Target Count Validator")
    parser.add_argument("--year", type=int, required=True, help="Target Year (e.g., 2022)")
    parser.add_argument("--month", type=int, help="Target Month (Optional, e.g., 8)")
    args = parser.parse_args()

    print("==================================================")
    print(f"--- 📊 [자동 교차 검증] {args.year}년 {args.month if args.month else '전체'} ---")
    print("==================================================")

    # Source와 Target을 동시에(병렬) 찔러서 대기 시간 단축
    with ThreadPoolExecutor(max_workers=2) as executor:
        future_source = executor.submit(get_facet_counts, SOURCE_SOLR, args.year, args.month)
        future_target = executor.submit(get_facet_counts, TARGET_SOLR, args.year, args.month)
        
        source_data = future_source.result()
        target_data = future_target.result()

    # 모든 날짜 키(Key)를 합집합으로 모음
    all_dates = sorted(list(set(source_data.keys()) | set(target_data.keys())))
    
    total_source = 0
    total_target = 0
    error_found = False

    print(f"{'날짜':<15} | {'Source 건수':<15} | {'Target 건수':<15} | {'차이(Diff)':<15}")
    print("-" * 65)

    for date in all_dates:
        s_count = source_data.get(date, 0)
        t_count = target_data.get(date, 0)
        diff = s_count - t_count
        
        total_source += s_count
        total_target += t_count

        if diff == 0:
            # 정상인 경우 (선택: 정상 일자도 보고 싶다면 주석 해제)
            # print(f"✅ {date:<13} | {s_count:<15,} | {t_count:<15,} | 일치")
            pass
        else:
            # 불일치 발생 시 즉각 표시
            error_found = True
            diff_str = f"누락 {-diff:,}" if diff > 0 else f"초과 {abs(diff):,}"
            print(f"❌ {date:<13} | {s_count:<15,} | {t_count:<15,} | {diff_str}")

    print("-" * 65)
    print(f"{'총합계':<14} | {total_source:<15,} | {total_target:<15,} | Diff: {total_source - total_target:,}")
    
    if not error_found:
        print("\n🎉 완벽합니다! 모든 일자의 데이터 건수가 100% 일치합니다.")
    else:
        print("\n🚨 경고: 데이터 건수가 일치하지 않는 일자가 발견되었습니다. 해당 일자의 로그나 ID를 확인하세요.")

if __name__ == "__main__":
    main()

