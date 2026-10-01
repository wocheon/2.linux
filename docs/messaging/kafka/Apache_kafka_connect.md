# Apache Kafka Connect

## 개요 
- Apache Kafka를 통해 DBMS 내 데이터 실시간 동기화(CDC)를 구현
- 각 DBMS 별 Connector 구성 (Mysql/MariaDB/PostgreDB)

## Apache Kafka Connect? 
- Apache Kafka의 데이터 통합 프레임워크
- 다양한 시스템과 Kafka 간 데이터를 손쉽게 전송하고 동기화할 수 있게 설계된 오픈소스 플랫폼
- 복잡한 커스텀 코드 없이도 데이터 소스와 싱크 간 신뢰성 높은 파이프라인 구축을 지원
- 확장 가능하고 분산 환경에 적합

### Apache Kafka Connect 주요 구성 요소

- Worker
    - 커넥터와 태스크를 실행하는 서버 프로세스
    - 단일 프로세스로 사용되는 Standalone 모드와 클러스터 형태로 구성되는 Distributed 모드 중 하나로 동작
    -  REST API를 제공하여 커넥터의 등록, 설정, 시작, 중지 명령을 받아 수행 

- Connector 
    - 외부 시스템과 Kafka 사이의 입출력 역할을 하는 플러그인
    - 소스(Source) 커넥터와 싱크(Sink) 커넥터로 구분

- Task
    - 커넥터가 분할한 실제 데이터 복사/전송 작업의 단위
    - 각 태스크는 독립적인 쓰레드로 실행
    - 상태를 저장하지 않고, 진행 상태(오프셋 등)는 Kafka 내부의 저장소에 기록

- offset
    - Kafka 토픽 기반 저장소에 기록되는 커넥터와 태스크가 처리한 데이터 위치
    - 커넥터 재시작 시 Offset을 통해 마지막 데이터 처리 시점 추적이 가능하며 미처리 데이터가 사라지지않음

- Transforms/Converters
    - Single Message Transform (SMT)
        -  커넥터에서 각각의 메시지에 대해 간단한 변형이나 필터링을 적용하는 기능
    - Connector
        - Kafka와 외부 시스템 간 데이터를 전달할 때 메시지 포맷(예: JSON, Avro 등) 변환을 담당


### Apache Kafka Connect 동작 방식 
1. Kafka Connect 워커가 커넥터를 로드하고, 태스크를 분산 배치하여 데이터 이동을 준비

2. Source Connector Task가 외부 시스템에서 변경 데이터를 읽어 Kafka 토픽에 전송

3. Sink Connector Task가 Kafka 토픽으로부터 메시지를 읽어 외부 시스템에 적재

4. 태스크 처리 상태는 Kafka 내부 토픽에 오프셋으로 저장
    -  복원/재시작 가능

5. 메시지는 필요에 따라 SMT를 통해 변환되며 컨버터를 통해 포맷을 통일 


### 대표적인 Kafka Connect 배포처

- Debezium
    - https://hub.docker.com/r/debezium/connect
    - 오픈소스 CDC 소스 커넥터 집합
    - MySQL, PostgreSQL, MongoDB, SQL Server 등 다양한 DBMS 변경 데이터를 Kafka에 스트리밍
    
    
- Confluent 
    - https://docs.confluent.io/platform/current/overview.html
    - Confluent사가 제공하는 엔터프라이즈 Kafka 배포판
    - Kafka Connect를 포함하며 관리형 UI, 보안, 모니터링, 다양한 커넥터를 지원

- Apache Kafka 공식 커넥터 
    - Apache Kafka 프로젝트 내 기본 제공하는 소스 및 싱크 커넥터 
        - EX) FileStream Source/Sink, JDBC Source/Sink 등


## Apache Kafka Connect 기반 CDC 아키텍쳐
- Apache Kafka Connect를 통해 DBMS 내 특정 테이블의 실시간 동기화 아키텍쳐를 구성 가능 
- Debezium에서 배포된 Connector를 사용하여 구성 
- kafka/kafka Connect는 Docker Container를 사용하여 구성

- 각 DB는 Docker Container로 구성
    - 테스트 용도이므로 별도 서버를 구성하지않고 Docker로만 구성하여 진행 

- Source Connector는 각 DBMS 별로 구성해야하며 Sink Connector는 JDBC Connector를 사용

### Apache Kafka Connect 기반 CDC 아키텍쳐 구성도 

```
[DBMS (Source)] 
      │
      │ CDC (변경 로그 / Transaction Log)
      ▼
[Kafka Connect Source Connector]
      │
      │ Kafka 토픽 (Change Events)
      ▼
      [Apache Kafka Broker]
      │
      │ Kafka 토픽 구독
      ▼
[Kafka Connect Sink Connector]
      │
      │ 변경 데이터 반영 (Insert/Update/Delete)
      ▼
[DBMS (Target) 또는 Data Lake / NoSQL 등]
```

## Apache Kafka/Apache Kafka Connect 구성 
- 각 아키텍쳐별로 사용될 Docker Network 구성 
```sh
docker network create mariadb-network
docker network create mysql-network
docker network create postgre-network
# kafka-network는 Docker-compose 실행시 자동 생성
```

- Docker-Compose로 kafka/kafka Connect 구성 
```yml
version: '3'
services:
  kafka:
    image: apache/kafka:3.9.1   # kafka 공식 Docker Image 사용
    container_name: kafka
    hostname: kafka
    ports:
      - "9092:9092"
      - "9093:9093"  # 컨트롤러 포트
    environment:
      KAFKA_CLUSTER_ID: "test-kafka-custer"  
      KAFKA_NODE_ID: 1
      KAFKA_PROCESS_ROLES: "broker,controller"
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_LOG_DIRS: /var/lib/kafka/data
    volumes:
      - kafka-data:/var/lib/kafka/data
    networks:
      - kafka-network
      - mariadb-network
      - mysql-network
      - postgre-network

  kafka-connect:
    image: debezium/connect:2.7.3.Final # Debezium 커넥터 Docker Image 사용
    container_name: kafka-connect
    depends_on:
      - kafka
    ports:
      - "8083:8083"
    environment:
      BOOTSTRAP_SERVERS: kafka:9092
      GROUP_ID: "1"
      CONFIG_STORAGE_TOPIC: "connect-configs"
      OFFSET_STORAGE_TOPIC: "connect-offsets"
      STATUS_STORAGE_TOPIC: "connect-status"
      KEY_CONVERTER_SCHEMAS_ENABLE: "false"
      VALUE_CONVERTER_SCHEMAS_ENABLE: "false"
      CONNECT_KEY_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_VALUE_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_PLUGIN_PATH: "/kafka/connect"
#    volumes:
#      - ./plugins:/kafka/connect   # 별도 플러그인 필요시 활성화 
    networks:
      - kafka-network
      - mariadb-network
      - mysql-network
      - postgre-network

networks:
  kafka-network:
    name: kafka-network
    driver: bridge
  mariadb-network:  # 기존 네트워크 지정시 External로 지정 필요
    external: true
    driver: bridge
    name: mariadb-network
  mysql-network:
    external: true
    driver: bridge
    name: mysql-network
  postgre-network:
    external: true
    driver: bridge
    name: postgre-network

volumes:
  kafka-data:
```

- docker-compose 로 컨테이너 실행 
```
docker-compose up -d 
WARN[0000] /home/ciw0707/docker_images/kafka_connect/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
[+] Running 4/4
 ✔ Network kafka-network              Created                                                                                                                                                               0.1s
 ✔ Volume "kafka_connect_kafka-data"  Created                                                                                                                                                               0.0s
 ✔ Container kafka                    Started                                                                                                                                                               0.7s
 ✔ Container kafka-connect            Started                                                                                                                                                               0.9s
```


- kafka topic리스트 조회 (정상동작 확인)
```
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```


- kafka Connect 내 사용가능한 Connector 목록 조회 
```sh 
curl -X GET  http://localhost:8083/connector-plugins | jq .
```


##  Apache Kafka Connect 기반 CDC 아키텍쳐 - MariaDB 

### Mariadb 구성 


#### DB 구성용 설정 파일 
- init.sql
```sql
create database if not exists connect_test_db;
create table if not exists connect_test_db.source_table (id int auto_increment primary key , name varchar(10));
```

- my_cnf/mariadb_main.cnf
```
[mariadb]
server_id=1
log_bin=mysql-bin
binlog_format=ROW
gtid_strict_mode=ON
gtid_domain_id=1
```

- my_cnf/mariadb_replica.cnf
```
[mariadb]
server_id=3
log_bin=mysql-bin
binlog_format=ROW
gtid_strict_mode=ON
gtid_domain_id=3
```

#### mariadb-main (Source) docker Container 

```sh
docker run -d \
  --name mariadb-main \
  --network mariadb-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=connect_test_db \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=appuserpass \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -v $(pwd)/my_cnf/mariadb_main.cnf:/etc/mysql/mariadb.cnf \
  -p 3306:3306 \
  mariadb:10.5.10
```

#### mariadb-replica (Sink) docker Container 

```sh
docker run -d \
  --name mariadb-replica \
  --network mariadb-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=connect_test_db \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=appuserpass \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -v $(pwd)/my_cnf/mariadb_replica.cnf:/etc/mysql/mariadb.cnf \
  -p 3307:3306 \
  mariadb:10.5.10
```


### Mariadb Connector 구성 

- Source Connector JSON 구성 
> connector_json/mariadb-source-connector.json
```json
{
"name": "mariadb-source-connector",
  "config": {
    "connector.class": "io.debezium.connector.mariadb.MariaDbConnector",
    "database.hostname": "mariadb-main",    #Docker 컨테이너 명으로 hostname 대체
    "database.port": "3306",
    "database.user": "root",
    "database.password": "rootpass",
    "database.server.id": "1",
    "topic.prefix": "mariadb_server",
    "database.allowPublicKeyRetrieval": "true",
    "database.ssl.mode": "DISABLED",
    "database.include.list": "connect_test_db",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.mariadb",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "true",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true"
  }
}
```

- Sink Connector JSON 구성 
> connector_json/mariadb-sink-connector.json
```json
{
  "name": "mariadb-sink-connector",
  "config": {
    "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
    "connection.url": "jdbc:mariadb://mariadb-replica:3306/connect_test_db?sslMode=DISABLED",
    "connection.username": "root",
    "connection.password": "rootpass",
    "topics": "mariadb_server.connect_test_db.source_table",
    "table.name.format": "target_table",
    "insert.mode": "upsert",
    "delete.enabled": "true",
    "primary.key.mode": "record_key",
    "primary.key.fields": "id",
    "schema.evolution": "basic",
    "auto.create": "true"
  }
}
```


- Source/Sink Connector 생성 

```bash
#!/bin/bash

cd connector_json

source_json="mariadb-source-connector.json"
sink_json="mariadb-sink-connector.json"

curl -X POST -H "Content-Type: application/json" --data @${source_json} http://localhost:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @${sink_json} http://localhost:8083/connectors
```

### Connector 정상 동작 확인 

```sh
# 생성된 connector 목록 확인
$ curl --location --request GET -H "Content-Type: application/json" http://localhost:8083/connectors
["mariadb-sink-connector","mariadb-source-connector"]

# source connector check
$ curl -s http://localhost:8083/connectors/mariadb-source-connector/status | jq
{
  "name": "mariadb-source-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.21.0.3:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.21.0.3:8083"
    }
  ],
  "type": "source"
}

# sink connector check
curl -s http://localhost:8083/connectors/mariadb-sink-connector/status | jq
{
  "name": "mariadb-sink-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.21.0.3:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.21.0.3:8083"
    }
  ],
  "type": "sink"
}
```


- Kafka Topic 리스트 확인
```sh 
$ docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
__consumer_offsets
connect-configs
connect-offsets
connect-status
mariadb_server
mariadb_server.connect_test_db.source_table 
schema-changes.mariadb
```



#### Connetor 동작 확인 

- mariadb-main.connect_test_db.source_table에 데이터 Insert/Update/Delete

```sql
insert into source_table (name) values ('test1');
insert into source_table (name) values ('test2');
insert into source_table (name) values ('test3');
insert into source_table (name) values ('test4');
insert into source_table (name) values ('test5');

update source_table set name='test4' where id=2;
delete from source_table where id=4;
```


- Kafka Conntor용 Topic 내 Message 확인 

```sh
$ docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic mariadb_server.connect_test_db.source_table --from-beginning --max-messages 10

{"schema":{"type":"struct","fields":[{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":true,"field":"name"}],"optional":true,"name":"mariadb_server.connect_test_db.source_table.Value","field":"before"},{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":true,"field":"name"}],"optional":true,"name":"mariadb_server.connect_test_db.source_table.Value","field":"after"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"version"},{"type":"string","optional":false,"field":"connector"},{"type":"string","optional":false,"field":"name"},{"type":"int64","optional":false,"field":"ts_ms"},{"type":"string","optional":true,"name":"io.debezium.data.Enum","version":1,"parameters":{"allowed":"true,last,false,incremental"},"default":"false","field":"snapshot"},{"type":"string","optional":false,"field":"db"},{"type":"string","optional":true,"field":"sequence"},{"type":"int64","optional":true,"field":"ts_us"},{"type":"int64","optional":true,"field":"ts_ns"},{"type":"string","optional":true,"field":"table"},{"type":"int64","optional":false,"field":"server_id"},{"type":"string","optional":true,"field":"gtid"},{"type":"string","optional":false,"field":"file"},{"type":"int64","optional":false,"field":"pos"},{"type":"int32","optional":false,"field":"row"},{"type":"int64","optional":true,"field":"thread"},{"type":"string","optional":true,"field":"query"}],"optional":false,"name":"io.debezium.connector.mariadb.Source","field":"source"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"id"},{"type":"int64","optional":false,"field":"total_order"},{"type":"int64","optional":false,"field":"data_collection_order"}],"optional":true,"name":"event.block","version":1,"field":"transaction"},{"type":"string","optional":false,"field":"op"},{"type":"int64","optional":true,"field":"ts_ms"},{"type":"int64","optional":true,"field":"ts_us"},{"type":"int64","optional":true,"field":"ts_ns"}],"optional":false,"name":"mariadb_server.connect_test_db.source_table.Envelope","version":2},"payload":{"before":null,"after":{"id":1,"name":"test1"},"source":{"version":"2.7.3.Final","connector":"mariadb","name":"mariadb_server","ts_ms":1756279375000,"snapshot":"false","db":"connect_test_db","sequence":null,"ts_us":1756279375000000,"ts_ns":1756279375000000000,"table":"source_table","server_id":1,"gtid":"1-1-7201","file":"mysql-bin.000003","pos":588,"row":0,"thread":null,"query":null},"transaction":null,"op":"c","ts_ms":1756279375309,"ts_us":1756279375309929,"ts_ns":1756279375309929712}}
```

- mariadb-replica.connect_test_db.target_table 에 데이터 동기화 확인

```sql
-- INSERT/UPDATE/DELETE 결과 모두 반영 확인
MariaDB [connect_test_db]> select * from target_table;
+----+-------+
| id | name  |
+----+-------+
|  1 | test1 |
|  2 | test4 |
|  3 | test3 |
|  5 | test5 |
+----+-------+
4 rows in set (0.001 sec)
```

### Mariadb Kafka Connector 삭제 
- Source/Sink 커넥터 삭제 

```sh 
$ curl -X DELETE "http://localhost:8083/connectors/mariadb-source-connector
$ curl -X DELETE "http://localhost:8083/connectors/mariadb-sink-connector
```

### Mariadb Kafka Connector Topic 삭제 
```
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic mariadb_server
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic mariadb_server.connect_test_db.source_table
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic schema-changes.mariadb
```

<br>

***

<br>



##  Apache Kafka Connect 기반 CDC 아키텍쳐 - Mysql 

### Mysql 구성 

#### DB 구성용 설정 파일 
- init.sql
```sql
create database if not exists connect_test_db;
create table if not exists connect_test_db.source_table (id int auto_increment primary key , name varchar(10));
```

- my_cnf/mysql-main.cnf
```
[mysqld]
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql
pid-file=/var/run/mysqld/mysqld.pid
server_id=1
log_bin=mysql-bin
binlog_format=ROW

[client]
socket=/var/run/mysqld/mysqld.sock
!includedir /etc/mysql/conf.d/
```

- my_cnf/mysql-replica.cnf
```
[mysqld]
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql
pid-file=/var/run/mysqld/mysqld.pid
server_id=2
log_bin=mysql-bin
binlog_format=ROW

[client]
socket=/var/run/mysqld/mysqld.sock
!includedir /etc/mysql/conf.d/
```

#### mysqldb-main (Source) docker Container 

```sh
docker run -d \
  --name mysqldb-main \
  --network mysql-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=connect_test_db \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=appuserpass \
  -v $(pwd)/my_cnf/mysql-main.cnf:/etc/my.cnf \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -p 3306:3306 \
  mysql:8.0
```

#### mysqldb-replica (Sink) docker Container 

```sh
docker run -d \
  --name mysqldb-replica \
  --network mysql-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=connect_test_db \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=appuserpass \
  -v $(pwd)/my_cnf/mysql-replica.cnf:/etc/my.cnf \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -p 3307:3306 \
  mysql:8.0
```

### Mysql Connector 구성 

- Source Connector JSON 구성 
> connector_json/mysql-source-connector.json
```json
{
  "name": "mysql-source-connector",
  "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "mysqldb",
        "database.port": "3306",
        "database.user": "root",
        "database.password": "rootpass",
        "database.server.id": "1",
        "database.allowPublicKeyRetrieval": "true",
        "database.ssl.mode": "disabled",
        "database.include.list": "connect_test_db",
        "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
        "schema.history.internal.kafka.topic": "schema-changes.mysql",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "true",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "true",
        "topic.prefix": "mysql_server"
  }
}
```

- Sink Connector JSON 구성 
> connector_json/mysql-sink-connector.json
```json
{
  "name": "mysql-sink-connector",
  "config": {
    "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
    "connection.url": "jdbc:mysql://mysqldb-b:3306/connect_test_db?sslMode=DISABLED",
    "connection.username": "root",
    "connection.password": "rootpass",
    "topics": "mysql_server.connect_test_db.source_table",
    "table.name.format": "target_table",
    "insert.mode": "upsert",
    "delete.enabled": "true",
    "primary.key.mode": "record_key",
    "primary.key.fields": "id",
    "schema.evolution": "basic",
    "auto.create": "true"
  }                                                                                                                                                         }
```

- Source/Sink Connector 생성 

```bash
#!/bin/bash

cd connector_json

# Mysql
source_json="mysql-source-connector.json"
sink_json="mysql-sink-connector.json"

curl -X POST -H "Content-Type: application/json" --data @${source_json} http://localhost:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @${sink_json} http://localhost:8083/connectors
```


### Connector 정상 동작 확인 

```sh
# 생성된 connector 목록 확인
$ curl --location --request GET -H "Content-Type: application/json" http://localhost:8083/connectors
["mysql-source-connector","mysql-sink-connector"]

# source connector check
$ curl -s http://localhost:8083/connectors/mysql-source-connector/status | jq
{
  "name": "mysql-source-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.19.0.3:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.19.0.3:8083"
    }
  ],
  "type": "source"
}

# sink connector check
curl -s http://localhost:8083/connectors/mysql-sink-connector/status | jq
{
  "name": "mysql-sink-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.19.0.3:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.19.0.3:8083"
    }
  ],
  "type": "sink"
}
```


- Kafka Topic 리스트 확인
```sh 
$ docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
__consumer_offsets
connect-configs
connect-offsets
connect-status
mysql_server
mysql_server.connect_test_db.source_table
schema-changes.mysql
```

#### Connetor 동작 확인 

- mysqldb-main.connect_test_db.source_table에 데이터 Insert/Update/Delete

```sql
insert into source_table (name) values ('test1');
insert into source_table (name) values ('test2');
insert into source_table (name) values ('test3');
insert into source_table (name) values ('test4');
insert into source_table (name) values ('test5');

update source_table set name='test4' where id=2;
delete from source_table where id=4;
```


- Kafka Conntor용 Topic 내 Message 확인 

```sh
$ docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic mysql_server.connect_test_db.source_table --from-beginning --max-messages 10

{"schema":{"type":"struct","fields":[{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":true,"field":"name"}],"optional":true,"name":"mysql_server.connect_test_db.source_table.Value","field":"before"},{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":true,"field":"name"}],"optional":true,"name":"mysql_server.connect_test_db.source_table.Value","field":"after"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"version"},{"type":"string","optional":false,"field":"connector"},{"type":"string","optional":false,"field":"name"},{"type":"int64","optional":false,"field":"ts_ms"},{"type":"string","optional":true,"name":"io.debezium.data.Enum","version":1,"parameters":{"allowed":"true,last,false,incremental"},"default":"false","field":"snapshot"},{"type":"string","optional":false,"field":"db"},{"type":"string","optional":true,"field":"sequence"},{"type":"int64","optional":true,"field":"ts_us"},{"type":"int64","optional":true,"field":"ts_ns"},{"type":"string","optional":true,"field":"table"},{"type":"int64","optional":false,"field":"server_id"},{"type":"string","optional":true,"field":"gtid"},{"type":"string","optional":false,"field":"file"},{"type":"int64","optional":false,"field":"pos"},{"type":"int32","optional":false,"field":"row"},{"type":"int64","optional":true,"field":"thread"},{"type":"string","optional":true,"field":"query"}],"optional":false,"name":"io.debezium.connector.mysql.Source","field":"source"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"id"},{"type":"int64","optional":false,"field":"total_order"},{"type":"int64","optional":false,"field":"data_collection_order"}],"optional":true,"name":"event.block","version":1,"field":"transaction"},{"type":"string","optional":false,"field":"op"},{"type":"int64","optional":true,"field":"ts_ms"},{"type":"int64","optional":true,"field":"ts_us"},{"type":"int64","optional":true,"field":"ts_ns"}],"optional":false,"name":"mysql_server.connect_test_db.source_table.Envelope","version":2},"payload":{"before":null,"after":{"id":1,"name":"test1"},"source":{"version":"2.7.3.Final","connector":"mysql","name":"mysql_server","ts_ms":1756281265000,"snapshot":"false","db":"connect_test_db","sequence":null,"ts_us":1756281265000000,"ts_ns":1756281265000000000,"table":"source_table","server_id":1,"gtid":null,"file":"mysql-bin.000003","pos":399,"row":0,"thread":10,"query":null},"transaction":null,"op":"c","ts_ms":1756281265624,"ts_us":1756281265624215,"ts_ns":1756281265624215797}}
```

- mysqldb-replica.connect_test_db.target_table 에 데이터 동기화 확인

```sql
-- target_table 테이블 자동 생성 확인
mysql> show tables;
+---------------------------+
| Tables_in_connect_test_db |
+---------------------------+
| source_table              |
| target_table              |
+---------------------------+
2 rows in set (0.00 sec)

-- INSERT/UPDATE/DELETE 결과 모두 반영 확인
mysql> select * from target_table;
+----+-------+
| id | name  |
+----+-------+
|  1 | test1 |
|  2 | test4 |
|  3 | test3 |
|  5 | test5 |
+----+-------+
4 rows in set (0.00 sec)
```


### Mariadb Kafka Connector 삭제 
- Source/Sink 커넥터 삭제 

```sh 
$ curl -X DELETE "http://localhost:8083/connectors/mysql-source-connector
$ curl -X DELETE "http://localhost:8083/connectors/mysql-sink-connector
```

### Mariadb Kafka Connector Topic 삭제 
```
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic mysql_server
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic mysql_server.connect_test_db.source_table
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic schema-changes.mysql
```

<br>

***

<br>

##  Apache Kafka Connect 기반 CDC 아키텍쳐 - PostgreSQL

### PostgreSQL 구성 

#### DB 구성용 설정 파일 
- init.sql
```sql
-- postgres의 경우 별도의 Pubilcation 설정이 있어야 정상적으로 kafka Topic에 전달됨
CREATE TABLE public.source_table (id SERIAL PRIMARY KEY, name VARCHAR(10));
CREATE PUBLICATION dbz_publication FOR TABLE public.source_table;
```

- custom_conf/custom-pg_hba.conf
```
# Allow replication connections from any IP with password
host    all     postgres        0.0.0.0/0      md5
host    all     testuser        0.0.0.0/0      md5
```

- custom_conf/custom-postgresql.conf
```
# PostgreSQL configuration for logical replication
listen_addresses = '*'
wal_level = logical
max_replication_slots = 4
max_wal_senders = 4
wal_keep_size = 64MB
max_worker_processes = 8
```

#### postgres-main (Source) docker Container 

```sh
docker run -d --name postgres-main \
  --network=postgre-network \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgrespass \
  -e POSTGRES_DB=connect_test_db \
  -v $(pwd)/custom_conf/custom-postgresql.conf:/etc/postgresql/postgresql.conf \
  -v $(pwd)/custom_conf/custom-pg_hba.conf:/etc/postgresql/pg_hba.conf \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  postgres:latest \
  -c config_file=/etc/postgresql/postgresql.conf
```

#### postgres-replica (Sink) docker Container 

```sh
docker run -d --name postgres-replica \
  --network=postgre-network \
  -p 5433:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgrespass \
  -e POSTGRES_DB=connect_test_db \
  -v $(pwd)/custom_conf/custom-postgresql.conf:/etc/postgresql/postgresql.conf \
  -v $(pwd)/custom_conf/custom-pg_hba.conf:/etc/postgresql/pg_hba.conf \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  postgres:latest \
  -c config_file=/etc/postgresql/postgresql.conf
```


### PostgreSQL Connector 구성 

- Source Connector JSON 구성 
> connector_json/postgresdb-source-connector.json
```json
{
  "name": "postgres-source-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "postgres-main",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "postgrespass",
    "database.dbname": "connect_test_db",
    "database.server.name": "postgres_server",
    "plugin.name": "pgoutput",
    "slot.name": "debezium_slot",
    "publication.name": "dbz_publication",
    "table.include.list": "public.source_table",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.postgres",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "true",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true",
    "topic.prefix": "postgres_server.connect_test_db"
  }
}
```

- Sink Connector JSON 구성 
> connector_json/postgresdb-sink-connector.json
```json
{
  "name": "postgres-sink-connector",
  "config": {
    "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
    "connection.url": "jdbc:postgresql://postgres-replica:5432/connect_test_db",
    "connection.username": "postgres",
    "connection.password": "postgrespass",
    "topics": "postgres_server.connect_test_db.public.source_table",
    "table.name.format": "target_table",
    "insert.mode": "upsert",
    "delete.enabled": "true",
    "primary.key.mode": "record_key",
    "primary.key.fields": "id",
    "schema.evolution": "basic",
    "auto.create": "true",
    "dialect.name": "org.hibernate.dialect.PostgreSQLDialect"
  }
}
```


- Source/Sink Connector 생성 

```bash
#!/bin/bash

cd connector_json

# Postgresql
source_json="postgresdb-source-connector.json"
sink_json="postgresdb-sink-connector.json"

curl -X POST -H "Content-Type: application/json" --data @${source_json} http://localhost:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @${sink_json} http://localhost:8083/connectors
```

### Connector 정상 동작 확인 

```sh
# 생성된 connector 목록 확인
$ curl --location --request GET -H "Content-Type: application/json" http://localhost:8083/connectors
["postgres-sink-connector","postgres-source-connector"]

# source connector check
$ curl -s http://localhost:8083/connectors/postgres-source-connector/status | jq
{
  "name": "postgres-source-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.19.0.3:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.19.0.3:8083"
    }
  ],
  "type": "source"
}

# sink connector check
curl -s http://localhost:8083/connectors/postgres-sink-connector/status | jq
{
  "name": "postgres-sink-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.19.0.3:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.19.0.3:8083"
    }
  ],
  "type": "sink"
}
```


- Kafka Topic 리스트 확인
    - PostgreDB용 Connector의 경우, schema.history.internal.kafka.topic 옵션을 지정하더라도 별도 토픽이 만들어지지 않음
    - Postgres Connector는는 logical decoding 플러그인(pgoutput, wal2json, decoderbufs)을 사용
        - MySQL/SQL Server: binlog에서 테이블 스키마를 직접 알 수 없어서 별도 히스토리 토픽 필요.
        - PostgreSQL: logical replication stream에서 테이블 구조 정보를 직접 제공하기 때문에 별도 토픽이 필요 없음.
```sh 
$ docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
__consumer_offsets
connect-configs
connect-offsets
connect-status
postgres_server.connect_test_db.public.source_table
# 기존과 다르게 schema-change.postgres 토픽은 생성되지않음
```

#### Connetor 동작 확인 

- postgres-main.connect_test_db.public.target_table에 데이터 Insert/Update/Delete

```sql
insert into public.source_table (name) values ('test1');
insert into public.source_table (name) values ('test2');
insert into public.source_table (name) values ('test3');
insert into public.source_table (name) values ('test4');
insert into public.source_table (name) values ('test5');

update public.source_table set name='test4' where id=2;
delete from public.source_table where id=4;
```


- Kafka Conntor용 Topic 내 Message 확인 

```sh
$ docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic postgres_server.connect_test_db.public.source_table --from-beginning --max-messages 10

{"schema":{"type":"struct","fields":[{"type":"struct","fields":[{"type":"int32","optional":false,"default":0,"field":"id"},{"type":"string","optional":true,"field":"name"}],"optional":true,"name":"postgres_server.connect_test_db.public.source_table.Value","field":"before"},{"type":"struct","fields":[{"type":"int32","optional":false,"default":0,"field":"id"},{"type":"string","optional":true,"field":"name"}],"optional":true,"name":"postgres_server.connect_test_db.public.source_table.Value","field":"after"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"version"},{"type":"string","optional":false,"field":"connector"},{"type":"string","optional":false,"field":"name"},{"type":"int64","optional":false,"field":"ts_ms"},{"type":"string","optional":true,"name":"io.debezium.data.Enum","version":1,"parameters":{"allowed":"true,last,false,incremental"},"default":"false","field":"snapshot"},{"type":"string","optional":false,"field":"db"},{"type":"string","optional":true,"field":"sequence"},{"type":"int64","optional":true,"field":"ts_us"},{"type":"int64","optional":true,"field":"ts_ns"},{"type":"string","optional":false,"field":"schema"},{"type":"string","optional":false,"field":"table"},{"type":"int64","optional":true,"field":"txId"},{"type":"int64","optional":true,"field":"lsn"},{"type":"int64","optional":true,"field":"xmin"}],"optional":false,"name":"io.debezium.connector.postgresql.Source","field":"source"},{"type":"struct","fields":[{"type":"string","optional":false,"field":"id"},{"type":"int64","optional":false,"field":"total_order"},{"type":"int64","optional":false,"field":"data_collection_order"}],"optional":true,"name":"event.block","version":1,"field":"transaction"},{"type":"string","optional":false,"field":"op"},{"type":"int64","optional":true,"field":"ts_ms"},{"type":"int64","optional":true,"field":"ts_us"},{"type":"int64","optional":true,"field":"ts_ns"}],"optional":false,"name":"postgres_server.connect_test_db.public.source_table.Envelope","version":2},"payload":{"before":null,"after":{"id":8,"name":"test1"},"source":{"version":"2.7.3.Final","connector":"postgresql","name":"postgres_server.connect_test_db","ts_ms":1756284839282,"snapshot":"false","db":"connect_test_db","sequence":"[\"26863880\",\"26863936\"]","ts_us":1756284839282114,"ts_ns":1756284839282114000,"schema":"public","table":"source_table","txId":780,"lsn":26863936,"xmin":null},"transaction":null,"op":"c","ts_ms":1756284839610,"ts_us":1756284839610999,"ts_ns":1756284839610999046}}
```

- postgres-replica.connect_test_db.public.target_table 에 데이터 동기화 확인

```sql
-- target_table 테이블 자동 생성 확인
connect_test_db=# SELECT table_schema, table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE'  AND table_schema NOT IN ('pg_catalog', 'information_schema');
 table_schema |  table_name
--------------+--------------
 public       | source_table
 public       | target_table
(2 rows)

-- INSERT/UPDATE/DELETE 결과 모두 반영 확인
connect_test_db=# select * from public.target_table;
 id | name
----+-------
  8 | test1
  9 | test2
 10 | test3
 11 | test4
 12 | test5
(5 rows)
```


### Mariadb Kafka Connector 삭제 
- Source/Sink 커넥터 삭제 

```sh 
$ curl -X DELETE "http://localhost:8083/connectors/postgres-source-connector
$ curl -X DELETE "http://localhost:8083/connectors/postgres-sink-connector
```

### Mariadb Kafka Connector Topic 삭제 
```
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic postgres_server.connect_test_db.public.source_table
```