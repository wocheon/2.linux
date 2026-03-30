# TRA 백업 테스트

## 개요 
- Solr TRA 컬렉션의 백업 및 복구 방법 정리 
  - 2022 ~ 2024 년의 데이터가 들어있는 TRA 컬렉션에서 22년 컬렉션을 삭제
  - 삭제한 22년 컬렉션을 다시 복구하여 TRA에 편입

## Solr TRA 컬렉션 백업

### 1. 2022년 TRA 백업 진행 
- 백업 대상 
  - 대상 : test_kr__TRA__2022-01-01
  - 위치 : gs://gcp-solr-gcs-backup-bucket/ (gcs_backup)
  - solr_tra_backups/tstamp_2022
  - ASYNC_ID : "gcs_backup_test_001"


- 백업 정상 여부 확인 
```bash
================================================
   Solr GCS Backup/Admin Manager
   URL: http://localhost:8983/solr
================================================
1) [BACKUP] Start Async Backup
2) [STATUS] Check Async Job Status
3) [LIST]   List Backups in Repository
4) [DELETE] Delete Backup Points (Retention)
5) [PURGE]  Purge Unused Files (GC)
6) [ADMIN]  Flush All Async Status
7) [RESTORE] Restore from Backup
q) Quit
------------------------------------------------
Select an option: 3
Backup Name [tstamp_2022]:
{
  "responseHeader": {
    "status": 0,
    "QTime": 510
  },
  "collection": "test_kr__TRA__2022-01-01",
  "backups": [
    {
      "backupId": 0,
      "indexVersion": "9.11.1",
      "startTime": "2026-03-26T04:37:42.193720062Z",
      "endTime": "2026-03-26T04:40:10.789230727Z",
      "indexFileCount": 2607,
      "indexSizeMB": 2258.5110000000004,
      "shardBackupIds": {
        "shard2": "md_shard2_0.json",
        "shard3": "md_shard3_0.json",
        "shard4": "md_shard4_0.json",
        "shard5": "md_shard5_0.json",
        "shard1": "md_shard1_0.json",
        "shard6": "md_shard6_0.json",
        "shard7": "md_shard7_0.json",
        "shard8": "md_shard8_0.json"
      },
      "collection.configName": "_default",
      "collectionAlias": "test_kr__TRA__2022-01-01"
    }
  ]
}
```


### 2. 백업 완료 후 기존 컬렉션 삭제
  
- 22년 컬렉션 삭제 시도
```bash
# ERROR 발생 
collection : test_kr__TRA__2022-01-01 is part of aliases: [test_kr], remove or modify the aliases before removing this collection.
-> TRA Alias를 수정하고 나서 삭제해야 함
```    

- 기존 TRA Alias를 삭제 하고 재생성 
	- 브라우저 혹은 API를 통해 `test_kr` Alias를 삭제 
	

- API 요청을 통해 23년부터 시작되는 TRA Alias 재생성 
	-  생성 후 23년은 자동으로 연결되지만 24년은 자동연결 X > 24년 데이터를 넣어야 연결됨
		- 기존 24년 데이터 1건만 이관해주면 다시 TRA Alias에 연결됨
	```bash
	curl -X GET "http://10.0.1.191:8983/solr/admin/collections?action=CREATEALIAS" \
	--data-urlencode "name=test_kr" \
	--data-urlencode "router.name=time" \
	--data-urlencode "router.field=tstamp" \
	--data-urlencode "router.start=2023-01-01T00:00:00Z" \
	--data-urlencode "router.interval=+1YEAR" \
	--data-urlencode "router.maxFutureMs=3600000" \
	--data-urlencode "create-collection.collection.configName=_default" \
	--data-urlencode "create-collection.numShards=8" \
	--data-urlencode "create-collection.replicationFactor=2" \
	--data-urlencode "create-collection.maxShardsPerNode=4"
	```


- TRA 재 구성 후 22년 TRA 컬렉션 삭제 완료 


### 4. 22년 컬렉션 복구 및 TRA 편입
- 22 년 컬렉션 복구
```bash
# GCS 백업에서 2022-01-01 컬렉션 복구
curl -X POST "http://localhost:8983/solr/admin/collections" \
  --data-urlencode "action=RESTORE" \
  --data-urlencode "name=tstamp_2022" \
  --data-urlencode "collection=collection__TRA__2022-01-01" \
  --data-urlencode "location=solr_tra_backups" \
  --data-urlencode "repository=gcs_backup" \
  --data-urlencode "async=restore_test_2022"
```


### 5. TRA alias 재정의 
- 동일하게 Alias 삭제 후 첫 TRA 구성시 사용한 API 호출 실행 
- 재정의 후,  23~24년 데이터 1건씩 넣어서 Alias 연결 
```bash
curl "http://localhost:8983/solr/admin/collections?action=CREATEALIAS\
&name=test_kr\
&router.name=time\
&router.field=tstamp\
&router.start=2022-01-01T00:00:00Z\
&router.interval=%2B1YEAR\
&router.maxFutureMs=3600000\
&create-collection.collection.configName=_default\
&create-collection.numShards=8\
&create-collection.replicationFactor=2\
&create-collection.maxShardsPerNode=4"
```

