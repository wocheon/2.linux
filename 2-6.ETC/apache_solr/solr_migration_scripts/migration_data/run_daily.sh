#!/bin/bash
# run_daily.sh

YEAR=2023
MONTH=4
MAX_CONCURRENT_JOBS=2

# 서브쉘(bash -c)에서 변수를 읽을 수 있도록 전역(export) 처리합니다.
export YEAR
export MONTH


# 로그 디렉토리 생성
mkdir -p logs

echo "=== ${YEAR}년 ${MONTH}월 데이터 안정적 병렬 마이그레이션 시작 ==="

# [수정된 부분] 튜플의 1번 인덱스만 가져와서 숫자만 추출합니다.
LAST_DAY=$(date -d "${YEAR}-${MONTH}-01 +1 month -1 day" +%d)

echo "해당 월의 마지막 날짜: ${LAST_DAY}일"
echo "동시 실행 프로세스 수: ${MAX_CONCURRENT_JOBS}"

# 1일부터 마지막 날까지 숫자 시퀀스 생성
seq 1 $LAST_DAY | xargs -P $MAX_CONCURRENT_JOBS -I {} bash -c '
    DAY={}
    echo "▶ [${YEAR}-${MONTH}-${DAY}] 일자 이관 시작..."
    
    # Python 출력 버퍼링 해제(-u) 및 로그 파일 저장
    python3 -u migrate.py --year '$YEAR' --month '$MONTH' --day $DAY > logs/migration_${YEAR}_${MONTH}_${DAY}.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ [${YEAR}-${MONTH}-${DAY}] 이관 완료"
    else
        echo "❌ [${YEAR}-${MONTH}-${DAY}] 이관 실패! (logs/migration_${YEAR}_${MONTH}_${DAY}.log 확인)"
    fi
'

echo "=== 마이그레이션 전체 종료. Target Solr 최종 커밋 실행 ==="
# TARGET_SOLR_URLS의 첫 번째 주소를 여기에 적어주세요.
curl -s "http://10.0.1191:8983/solr/test_kr/update?commit=true" > /dev/null
echo "최종 완료되었습니다."
