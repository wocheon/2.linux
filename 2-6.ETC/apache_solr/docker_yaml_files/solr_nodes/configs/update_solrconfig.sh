#!/bin/bash

# ==============================================================================
# 환경 설정
# ==============================================================================
LOCAL_EDITED_FILE="./solrconfig_edit.xml"
CONTAINER_TARGET_PATH="/opt/solr/server/solr/configsets/_default/conf/solrconfig.xml"

echo "==== 홀수/짝수 포트 라우팅 기반 Solr 설정 배포 스크립트 ===="

if [ ! -f "$LOCAL_EDITED_FILE" ]; then
    echo "[에러] $LOCAL_EDITED_FILE 파일이 존재하지 않습니다."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "[에러] jq 패키지가 설치되어 있지 않습니다."
    exit 1
fi

# 이름이 'solr'로 시작하는 실행 중인 컨테이너 목록만 추출 (예: solr1, solr2, solr3)
CONTAINERS=$(docker ps --filter "status=running" --filter "name=^/?solr[0-9]+" --format "{{.Names}}")

if [ -z "$CONTAINERS" ]; then
    echo "[경고] 조건에 맞는 실행 중인 Solr 컨테이너가 없습니다."
    exit 0
fi

echo "발견된 대상 컨테이너:"
echo "$CONTAINERS"
echo "------------------------------------------------------------"

# ==============================================================================
# 메인 루프: 컨테이너별 포트 계산 및 배포
# ==============================================================================
for CONTAINER in $CONTAINERS; do
    echo "▶ [컨테이너: $CONTAINER] 작업 시작"

    # 1. 컨테이너 이름에서 숫자만 추출 (solr1 -> 1, solr12 -> 12)
    NUM=$(echo "$CONTAINER" | grep -o -E '[0-9]+')

    if [ -z "$NUM" ]; then
        echo "   [경고] 컨테이너 이름에서 숫자를 찾을 수 없어 건너뜁니다."
        continue
    fi

    # 2. 홀수/짝수 판별을 통한 포트 할당
    if [ $((NUM % 2)) -eq 1 ]; then
        PORT=8983  # 홀수
    else
        PORT=8984  # 짝수
    fi
    echo "   - 할당된 타겟 포트: $PORT"

    # 3. 설정 파일 강제 덮어쓰기 (CP)
    echo "   - 설정 파일 복사 중 ($CONTAINER 내부로)..."
    docker cp "$LOCAL_EDITED_FILE" "$CONTAINER:$CONTAINER_TARGET_PATH"

    if [ $? -ne 0 ]; then
        echo "   [실패] 파일 복사 중 오류 발생"
        continue
    fi

    # 4. 호스트 네트워크를 통한 코어 목록 조회 (계산된 PORT 사용)
    echo "   - 코어(Core) 목록 조회 중 (http://localhost:$PORT)..."
    CORES=$(curl -s "http://localhost:$PORT/solr/admin/cores?wt=json" | jq -r '.status | keys[]' 2>/dev/null)

    if [ -z "$CORES" ]; then
        echo "   [경고] 이 컨테이너(포트 $PORT)에는 활성화된 코어가 없거나 응답이 없습니다."
        continue
    fi

    # 5. 개별 코어 리로드(Reload)
    for CORE in $CORES; do
        echo "     -> 코어 리로드 실행: [$CORE]"
        RELOAD_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/solr/admin/cores?action=RELOAD&core=$CORE")

        if [ "$RELOAD_RESPONSE" -eq 200 ]; then
            echo "        [성공] $CORE 리로드 완료 (HTTP 200)"
        else
            echo "        [실패] $CORE 리로드 실패 (HTTP $RELOAD_RESPONSE)"
        fi
    done

    echo "   [컨테이너: $CONTAINER] 작업 완료"
    echo "------------------------------------------------------------"
done

echo "==== 모든 배포 및 리로드가 완료되었습니다. ===="

