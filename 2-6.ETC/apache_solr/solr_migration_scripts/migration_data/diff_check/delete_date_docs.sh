#!/bin/bash
SOLR_NODE_IP="10.0.1191"
COLLECTION_NAME="test_kr__TRA__2024-01-01"

# 1. JSON 페이로드 파일 생성 (문법 오류 원천 차단)
cat <<EOF > delete_payload.json
{
  "delete": {
    "query": "tstamp:[2024-05-17T00:00:00Z TO 2024-05-17T23:59:59Z]"
  }
}
EOF

# 2. 파일을 이용한 API 호출 (에러 메시지 전문 출력)
curl -X POST -H 'Content-Type: application/json' \
  --data-binary @delete_payload.json \
  "http://${SOLR_NODE_IP}:8983/solr/${COLLECTION_NAME}/update?commit=true"

rm -rf delete_payload.json
