# ==========================================
# 설정 (Configuration)
# ==========================================
#solrURL='http://10.0.1191:8983/solr'
solrURL='http://localhost/solr'
collectionName='test_kr'
SOLR_BASE="${solrURL}/${collectionName}"
ENV="DEV"

# 문서 1건을 들여쓰기 된 JSON으로 출력
curl -s "${SOLR_BASE}/select?q=*:*&rows=50&wt=json" | \
  jq '.response.docs | map(del(._version_))' > sample_docs.json

