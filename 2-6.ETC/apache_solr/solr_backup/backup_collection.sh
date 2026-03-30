#!/bin/bash

collection_name='test_kr__TRA__2023-01-01'
backupfile_name='tstamp_2023'
async_name='gcs_backup_test_001'

# 1. 비동기 백업 요청 (async=backup_req_001 지정)
# <TARGET_COLLECTION>: 백업할 컬렉션 이름
# /var/solr/data/my_backups: 컨테이너 내부의 백업 디렉토리 (사전에 마운트 및 생성되어 있어야 함)
curl -X POST "http://localhost:8983/solr/admin/collections" \
  --data-urlencode "action=BACKUP" \
  --data-urlencode "name=${backupfile_name}" \
  --data-urlencode "collection=${collection_name}" \
  --data-urlencode "repository=gcs_backup" \
  --data-urlencode "location=solr_tra_backups" \
  --data-urlencode "async=${async_name}"


# 2. 비동기 백업 진행 상태(Status) 확인
# "state": "running" 또는 "completed", "failed" 등으로 출력됩니다.
curl "http://localhost:8983/solr/admin/collections?action=REQUESTSTATUS&requestid=${async_name}"

# 특정 Request ID 삭제 (Ready-to-run)
#curl -s "http://localhost:8983/solr/admin/collections?action=DELETESTATUS&requestid=backup_req_001"

# 모든 비동기 작업 기록(성공/실패 포함) 일괄 삭제
#curl -s "http://localhost:8983/solr/admin/collections?action=DELETESTATUS&flush=true"

# 특정 Backup ID 삭제 (Ready-to-run)
#curl -s "http://localhost:8983/solr/admin/collections" \
#  --data-urlencode "action=DELETEBACKUP" \
#  --data-urlencode "name=my_backups" \
#  --data-urlencode "repository=gcs_backup" \
#  --data-urlencode "location=solr_tra_backups" \
#  --data-urlencode "backupId=1"


## 백업 목록 확인 (Ready-to-run)
#curl -s "http://localhost:8983/solr/admin/collections" \
#  --data-urlencode "action=LISTBACKUP" \
#  --data-urlencode "location=solr_tra_backups" \
#  --data-urlencode "name=my_backups" \
#  --data-urlencode "repository=gcs_backup"


# 모든 백업 포인트 삭제
#curl -s "http://localhost:8983/solr/admin/collections" \
#  --data-urlencode "action=DELETEBACKUP" \
#  --data-urlencode "repository=gcs_backup" \
#  --data-urlencode "location=solr_tra_backups" \
#  --data-urlencode "maxNumBackupPoints=0"


## 실제 디스크/GCS 용량 확보를 위한 정리 작업
#curl -s "http://localhost:8983/solr/admin/collections" \
#  --data-urlencode "action=DELETEBACKUP" \
#  --data-urlencode "name=solr_backups" \
#  --data-urlencode "repository=gcs_backup" \
#  --data-urlencode "location=solr_tra_backups" \
#  --data-urlencode "purgeUnused=true"



