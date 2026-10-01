# 2022-01-01 컬렉션 복구 및 TRA 별칭 재정의
# 1. GCS 백업에서 2022-01-01 컬렉션 복구
# 2. TRA 별칭 재정의 (모든 라우팅 속성 포함)

# GCS 백업에서 2022-01-01 컬렉션 복구
curl -X POST "http://localhost:8983/solr/admin/collections" \
  --data-urlencode "action=RESTORE" \
  --data-urlencode "name=tstamp_2022" \
  --data-urlencode "collection=collection__TRA__2022-01-01" \
  --data-urlencode "location=solr_tra_backups" \
  --data-urlencode "repository=gcs_backup" \
  --data-urlencode "async=restore_test_2022"



  
# TRA 별칭 재정의 (모든 라우팅 속성 포함)
curl -X POST "http://localhost:8983/solr/admin/collections" \
  --data-urlencode "action=CREATEALIAS" \
  --data-urlencode "name=my_tra_alias" \
  --data-urlencode "collections=collection__TRA__2022-01-01,collection__TRA__2022-01-02" \
  --data-urlencode "router.name=time" \
  --data-urlencode "router.field=event_time" \
  --data-urlencode "router.start=2022-01-01T00:00:00Z" \
  --data-urlencode "router.interval=+1DAY" \
  --data-urlencode "create-collection.collection.configName=tra_config"