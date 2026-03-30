#!/bin/bash
# run_daily.sh

# 1. 사용법 정의 (Usage)
usage() {
    echo "오류: 필수 파라미터가 누락되었습니다."
    echo "사용법: $0 --year <YYYY> --month <MM>"
    echo "예시: $0 --year 2023 --month 04"
    exit 1
}

# 2. 파라미터 파싱
CHILD_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --year) YEAR="$2"; shift 2 ;;
        --month) MONTH="$2"; shift 2 ;;
        --child) CHILD_MODE=true; shift ;;
        *) shift ;;
    esac
done

# 3. 필수 인자 유효성 검사
if [[ -z "$YEAR" || -z "$MONTH" ]]; then
    usage
fi

# 4. 자기 자신을 백그라운드로 재귀 실행 (Self-Daemonization)
if [[ "$CHILD_MODE" == false ]]; then
    mkdir -p logs
    today_ymd=$(date '+%y%m%d_%H%M%S')
    main_log="logs/batch_main_${YEAR}${MONTH}_${today_ymd}.log"

    echo "=== 백그라운드 모드로 전환합니다 ==="
    echo "메인 로그: $main_log"
    
    # --child 플래그를 추가하여 재귀 호출 (무한루프 방지)
    nohup bash "$0" --child --year "$YEAR" --month "$MONTH" > "$main_log" 2>&1 &
    exit 0
fi

# ---------------------------------------------------------
# 여기서부터 실제 백그라운드에서 실행되는 로직입니다.
# ---------------------------------------------------------

MAX_CONCURRENT_JOBS=2
export YEAR MONTH

# 로그 디렉토리 생성
mkdir -p logs

echo "=== [$(date)] ${YEAR}년 ${MONTH}월 데이터 마이그레이션 시작 ==="

# 해당 월의 마지막 날짜 계산 (OS X/Linux 호환성 고려)
LAST_DAY=$(date -d "${YEAR}-${MONTH}-01 +1 month -1 day" +%d)

echo "대상 월 마지막 일: ${LAST_DAY}일"
echo "병렬 처리 수: ${MAX_CONCURRENT_JOBS}"


seq 1 "$LAST_DAY" | xargs -P "$MAX_CONCURRENT_JOBS" -I {} bash -c '
    # 위치 매개변수로 안전하게 할당받음
    YEAR=$1
    MONTH=$2
    DAY=$3

    # date 명령어의 띄어쓰기를 더블 쿼트("")로 안전하게 묶음.
    # 변수로 캐싱하여 불필요한 시스템 콜(System Call) 최소화
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

    echo "[$CURRENT_TIME] ▶ [${YEAR}-${MONTH}-${DAY}] 이관 시작..."

    # Python 출력 버퍼링 해제 및 일자별 로그 기록
    python3 -u migrate.py --year "$YEAR" --month "$MONTH" --day "$DAY" > "logs/migration_${YEAR}_${MONTH}_${DAY}.log" 2>&1

    # 실행 결과(Exit Status) 검증
    if [ $? -eq 0 ]; then
        SUCCESS_TIME=$(date "+%Y-%m-%d %H:%M:%S")
        echo "[$SUCCESS_TIME] ✅ [${YEAR}-${MONTH}-${DAY}] 이관 완료"
    else
        FAIL_TIME=$(date "+%Y-%m-%d %H:%M:%S")
        echo "[$FAIL_TIME] ❌ [${YEAR}-${MONTH}-${DAY}] 이관 실패! (logs/migration_${YEAR}_${MONTH}_${DAY}.log 확인)"
    fi
' _ "$YEAR" "$MONTH" "{}"

echo "=== [$(date)] 마이그레이션 완료. Solr Commit 실행 ==="
# Solr 최종 커밋 (실제 URL로 수정 필요)
curl -s "http://10.0.1191:8983/solr/test_kr/update?commit=true" > /dev/null

mkdir -p logs/${YEAR}_${MONTH}/
mv logs/migration_${YEAR}_${MONTH}_*  logs/${YEAR}_${MONTH}/
echo "모든 작업이 종료되었습니다."
