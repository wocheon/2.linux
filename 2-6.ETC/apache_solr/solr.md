
## solr 구성 개념 정리 

### 참고 - Solr Cloud 구성 예시
```
# - Solr Cloud (4 Shards, 2 Replicas)

   ___________                     
  | Zookeepers|                                      ___ shard1_replica1 
  | (3 VMs)   |      _________________ shard1 (VM1) |___ shard4_replica2
  |           |     |             |
  |  [ZK #1]  |     |             |
  |           |     |             |                   ___ shard1_replica2
  |  [ZK #2]  | <=> |  collection |____ shard2 (VM2) |___ shard2_replica1 
  |           |     |             |
  |  [ZK #3]  |     |             |
  |___________|     |             |                   ___ shard2_replica2
                    |_____________|____ shard3 (VM3) |___ shard3_replica1
                                  |
                                  |
                                  |                   ___ shard3_replica2
                                  |____ shard4 (VM4) |___ shard4_replica1
```

### 노드(Node)
- Solr 실행 프로세스
- Solr가 실행되는 하나의 프로세스 (현재 4개 노드로 구성됨)


### 컬렉션(Collection)
- 논리적 테이블
    - ex) test_kr(PRD), test_kr(DEV)

### 샤드(Shard)
- 컬렉션을 분산하여 저장하는 단위 
    - ex) test_kr 컬렉션은 4샤드로 분할 구성 

### 레플리카(replica)
- 샤드의 복제본. 
- 데이터 유실을 막기위해 원본(leader)와 사본으로 구성 
    - ex) 현재 test_kr의 구성은 4shard 2replica 구성

### 코어(Core)
-  레플리카가 디스크에 저장되고 메모리에 로드된 실제 형태 
    - **코어수 = 샤드 x 레플리카 수**

### 스키마(Schema)
-  solr 내 문서가 어떤 필드로 구성되는지 정의한 XML 파일 
    - ex) title 필드(text_kr) : 문서에 해당필드가 있다면 text_kr로 저장 
		
### zookeeper 
- 설정파일 (schema.xml, solrconfig.xml 등)을 중앙관리하고 레플리카의 리더를 관리하는 역할 				

- solr cloud 구성의 필수 요소 (없으면 solr 클라우드 동작 x)


## Solr Cloud 구성

### Solr Cloud 
- 대용량 데이터를 처리하기위한 solr 아키텍쳐
- 데이터를 쪼개서(샤드) 분산저장하며, 복제본(레플리카)를 둬서 안정성을 확보하고 이를 zookeeper로 관리하는 형태 

#### Solr Cloud의 분산처리 방식 
- Solr Cloud의 분산처리는 클라이언트의 요청 방식에 따라 달라짐 

- 일반 HTTP 호출 
	- curl 처럼 특정 노드에 요청을 직접 보내는 방식 (현재 사용방식)
			
	- 쿼리 실행 흐름 
		1. Client 가 Solr Node 의 IP를 통해 직접 요청 
		2. 요청을 받은 노드A가 조정자(Coordinator) 역할을 하며 Zookeeper를 통해 샤드 구성을 확인
		3. 검색이 필요한 샤드를 판단하고 검색을 진행 
		4. 노드 A는 이를 정렬하고 합쳐서 최종결과를 클라이언트에 반환 
		-> 특정 노드에 부하가 발생가능. 부하 발생을 억제하기위해 별도 LB 필요 					
	
- JAVA CloudSolrClient 사용 
	- zookeeper와 직접 통신하여 클라이언트가 알아서 번갈아가며 노드에 직접 요청 
	- Coordinator 병목 없음 
		

## Solr 메이저 버전 간 주요 차이점 


| 구분       | Solr 5.x (Legacy) | Solr 6.x        | Solr 7.x              | Solr 8.x            | Solr 9.x (Modern)      |
| -------- | ----------------- | --------------- | --------------------- | ------------------- | ---------------------- |
| 출시 년도    | 2015년             | 2016년           | 2017년                 | 2019년               | 2022년~현재               |
| Java 버전  | Java 7 or 8       | Java 8          | Java 8                | Java 8 or 11        | Java 11 (Min), 17+     |
| 배포 방식    | WAR (Tomcat 가능)   | Standalone 강제   | Standalone            | Standalone          | Docker / Kubernetes    |
| Index 호환 | Lucene 5.x        | Lucene 6.x      | Lucene 7.x            | Lucene 8.x          | Lucene 9.x (호환 불가)     |
| 주요 기능    | JSON Facet API    | Parallel SQL    | v2 API, Replica Types | HTTP/2, Security    | Vector Search, Modules |
| DIH 지원   | 기본 내장             | 기본 내장           | 기본 내장                 | 기본 내장 (Deprecated)  | 삭제됨 (별도 관리)            |
| 클러스터     | Zookeeper 기반      | Graph Traversal | Auto-scaling (초기)     | Auto-scaling (제거예고) | Placement Plugins      |

*** 버전 업그레이드 후에도 Solr Cloud 구성을 위해서는 여전히 Zookeeper 연동 필요

### Solr 6
- Standalone 모드 표준화 
    - Tomcat에 WAR 배포하는 방식 대신 bin/solr를 통해 직접 실행 
- Parallel SQL 도입
    - SQL 쿼리를 사용한 Solr 조회 기능을 추가

### Solr 7
- v2 API 도입
    - RESTful 한 구조의 새로운 API(/api/...)가 도입
- Replica Types 세분화 
    - replica구성시 NRT, TLOG, PULL 중 하나로 지정 가능 (Default : NRT)

- 각 Replica Type 별 특징

| 구분                      | NRT (Near Real Time)                | TLOG (Transaction Log)           | PULL                                 |
| ----------------------- | ----------------------------------- | -------------------------------- | ------------------------------------ |
| 역할 (Role)               | All-Rounder(색인 + 검색 + 리더 후보)        | Safety Net(로그 저장 + 리더 후보)        | Search Only(오직 검색 전담)                |
| 데이터 동기화                 | 리더로부터 **문서(Document)**를 받아 직접 색인 수행 | 리더로부터 문서를 받지만 색인 안 함 (로그만 기록)    | 리더가 만든 **세그먼트 파일(File)**을 주기적으로 복사해옴 |
| CPU 부하 (색인 시)           | 높음 (High)모든 노드가 각자 색인 작업 수행         | 낮음 (Low)색인 과정 생략, 로그만 씀          | 매우 낮음 (Minimal)색인 부하 0, 파일 복사만 수행    |
| 검색 반영 속도                | 즉시 (Real-Time)Soft Commit 지원        | 느림 (Latent)Hard Commit 후 반영됨     | 가장 느림 (Periodic)파일 복사 주기 의존          |
| 리더 승격 (Leader Election) | 가능 (Possible)최우선 순위 후보              | 가능 (Possible)데이터 손실 없이 승격 가능     | 불가능 (Impossible)절대 리더가 될 수 없음        |
| 추천 시나리오                 | 실시간 검색이 중요하고, 색인 양이 적당할 때 (기본값)     | 쓰기(Indexing) 부하가 심해 리더를 보호해야 할 때 | 검색 트래픽이 폭주하여 읽기 전용 노드가 필요할 때         |

- 기본 응답 포맷 변경 
    - 응답 포맷의 기본값이 **XML -> JSON** 으로 변경
        - config를 변경하면 다시 xml로도 변경 가능

### Solr 8 
- HTTP/2 지원을 통한 노드간 통신 효율 개선
    - 하나의 TCP 연결로 여러 검색 요청 동시 처리 가능 
    - 대규모 샤드 환경에서 네트워크 오버헤드가 크게 감소 

- 인증/인가 플러그인의 추가로 보안강화
- Nest Docs(중첩문서) 처리 개선을 통해 복잡한 데이터 모델링 가능 
    - 부모/자식 문서 등의 관계형 데이터를 구성 가능 

### Solr 9 
- AI 임베딩 벡터를 저장 및 검색 가능 (RAG 구현 가능)
- 추가 기능들을 별도 모듈로 분리하여 Solr 바이너리 크기를 감소
- 보안 및 유지보수 문제로 인해 DataImportHandler(DIH) 삭제
    - DIH :  DB데이터를 SQL로 불러와서 Solr로 넣는 ETL 도구 

## 메이저 버전 이관 시 주요 고려사항 

- 필드 타입 세대 교체 및 최적화  
    - 기존 버전에서 성능 문제 등으로 인해 삭제된 데이터 타입이 존재하므로 주의 필요

    ex) 필드타입 변경 필요 대상 

| 카테고리 | Legacy Type (Solr 5.x)                                   | Modern Type (Solr 9.x)                                     | 핵심 변경 사유 (Why Change?)                               |
| ---- | -------------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------- |
| 정수형  | solr.TrieIntField (tint)                                 | solr.IntPointField (pint)                                  | BKD-Tree 구조로 전환. 범위 검색 속도 획기적 개선 및 인덱스 용량 절감.        |
| 실수형  | solr.TrieLongField (tlong)solr.TrieDoubleField (tdouble) | solr.LongPointField (plong)solr.DoublePointField (pdouble) | (상동) 메모리 사용 효율성 증대.                                  |
| 날짜형  | solr.TrieDateField (tdate)                               | solr.DatePointField (pdate)                                | 날짜 연산 및 범위 필터링 최적화. (구버전 date 타입은 완전 삭제됨)            |
| 공간형  | solr.LatLonTypesolr.SpatialRecursivePrefixTree...        | solr.LatLonPointSpatialField                               | 기존 공간 검색 대비 인덱싱 속도 및 쿼리 정확도 향상.                      |
| 통화형  | solr.CurrencyField                                       | solr.CurrencyFieldType                                     | 환율 정보 처리 방식 변경. XML 설정 구조 최적화 및 동적 필드 연계 강화.         |
| 열거형  | solr.EnumField                                           | solr.EnumFieldType                                         | 정렬 로직 개선. enums.xml 설정 파일 경로 확인 필요.                  |
| 불리언  | solr.BoolField                                           | solr.BoolField (동일)                                        | 타입명은 같으나, docValues="true" 설정이 필수 권장됨 (Facet 성능 향상). |


- 기타 추천 사항 
    - docValues 표준화
        - 검색엔진 성능 최정화를 위해 도입된 정방향 인덱스,컬럼 저장소 
        - Solr 9.x에서는 텍스트 분석이 필요 없는 모든 필드(숫자, 날짜, 키워드 문자열)에 docValues="true"를 적용하는 것이 Best Practice
            - HEAP 메모리 절약, 읽기성능 증가 등 이점            
    - indexed=false 활용
        - 단순히 저장만 하고 검색 조건으로 쓰지 않는 필드는 indexed="false", docValues="true" 조합으로 설정하여 인덱스 크기를 줄이고 성능을 확보
    - useDocValuesAsStored
        - 저장된 값(stored="true")을 별도로 유지하지 않고 DocValues에서 값을 복원해 리턴하는 기능을 활용하여 스토리지 공간을 절약 가능


- 스키마 관리 방식 변화 
    - 기존 
        - 파일 시스템 내의 schema.xml 파일을 직접 편집기로 수정 
    - 변경 
        - schema API를 통해 제어 (POST /api/collections/{collection}/schema)
        - 운영 중 중단 없이 필드 추가 및 속성 변경 가능 


- 데이터 재색인(re-indexing) 필요 
    - 기존 Solr의 데이터는 하나의 메이저 버전 까지만 호환 가능 
    ex)  5.x 인덱스는 6.x에서 까지만 호환 
    - 기존 데이터를 그대로 복사해서 사용하는 것이 아닌 데이터 이관 작업을 통해 재색인이 필요함 (별도 re-indexing 스크립트를 통해 이관 진행)


- '아리랑(Arirang)' 형태소 분석기 호환성 문제
    - Solr 9.x 버전에서는 Lucene API 변경으로 인해 '아리랑(Arirang)' 형태소 분석기 사용 불가 (text_kr 등의 필드 생성이 불가)
    - Solr 6.6 / Lucene 7.4 버전부터 **공식 내장(Built-in)**된 한국어 형태소 분석기인 **Nori(노리)** 사용 권장 
        - 스키마 이관용 스크립트 참고 


- 참고 - Analyzer & Filter 변경 사항 (텍스트 분석)

| Legacy Component (Solr 5.x)     | Modern Component (Solr 9.x)          | 변경 사유 및 조치                                             |
| ------------------------------- | ------------------------------------ | ------------------------------------------------------ |
| solr.StandardFilterFactory      | (삭제됨)                                | 더 이상 필요하지 않습니다. 설정에서 제거하세요.                            |
| solr.WordDelimiterFilterFactory | solr.WordDelimiterGraphFilterFactory | 기존 필터는 다중 토큰 처리 시 오프셋 문제가 있었습니다. Graph 기반 필터로 교체 권장.   |
| solr.SynonymFilterFactory       | solr.SynonymGraphFilterFactory       | 동의어 처리 시(특히 다중 단어 동의어) 정확도가 향상됩니다. (Query Time에 사용 권장) |
| solr.LowerCaseFilterFactory     | (유지)                                 | 가장 기본적인 필터이므로 그대로 사용 가능합니다.                            |


- TRA(Time Routed Alias) 기능 적용 검토 
    - solr 9 버전부터 사용가능한 자동화된 시계열 데이터 관리기능 
    - 특정 필드를 기준으로 하여 컬렉션을 파티션 형태로 자동 분할하여 저장하는 기능 
    - 분할된 컬렉션들은 Alias로 지정되면서 원본 파티션으로도 호출이 가능
    - 자주 접근하는 최근 데이터를 Hot으로 두고 나머지 오래된 데이터는 Cold Data로 둬서 메모리 사용률을 낮출수 있음
    - 오래된 데이터를 자동 삭제하도록 설정가능
    - 컬렉션 분할로 인한 관리 포인트가 증가할 수있어 적용 전 검토 필요
    - ex) TRA 적용 컬렉션 구성 예시 
        - 기준 필드 : tstamp
        - NumShard : 1 
        - Replica : 2 
        - MaxShardPerNode : 4 
        - 2025-01-01 부터 36개월간 데이터 유지 
        ```
        curl "http://localhost:8983/solr/admin/collections?action=CREATEALIAS\
        &name=test_kr\
        &router.name=time\
        &router.field=tstamp\
        &router.start=2025-01-01T00:00:00Z\
        &router.interval=%2B1MONTH\
        &router.maxFutureMs=3600000\
        &router.autoDeleteAge=-36MONTHS\
        &create-collection.collection.configName=_default\
        &create-collection.numShards=1\
        &create-collection.replicationFactor=2\
        &create-collection.maxShardsPerNode=4"
        ```