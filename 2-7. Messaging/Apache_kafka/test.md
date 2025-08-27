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

