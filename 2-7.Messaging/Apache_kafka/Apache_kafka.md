# Apache Kafka

##  Apache Kafka ? 
- 대규모 실시간 데이터 스트리밍을 처리하는 데 특화된 분산 메시징 시스템
- 주로 데이터 파이프라인, 실시간 분석, 로그 수집, 이벤트 기반 아키텍처 등에 사용
- 기본 9092 포트 사용

### Apache Kafka 구성 요소

- Producer
    - Kafka에 메시지를 보내는 애플리케이션.
    - 주로 JSON, Avro, String 등 메시지 형식을 사용함.

- Consumer
    - Kafka로부터 메시지를 읽는 애플리케이션.

- Broker
    - Kafka 서버의 단일 인스턴스.
    - 일반적으로 여러 Broker를 클러스터로 묶어 사용.
    - 각각의 토픽(topic) 은 여러 개의 파티션(partition) 으로 나뉘고, 파티션은 여러 Broker에 분산됨.

- Topic
    - 메시지가 분류되어 저장되는 이름 단위.
    - 예: login-events, purchase-orders, user-activity 등.

- Zookeeper
    - Kafka 클러스터 상태를 관리 (리더 선출, 설정 저장 등).
    - Kafka 2.8 이후부터는 Zookeeper 없이 동작하는 KRaft 모드도 제공됨.
        - Kafka 2.8 이전: 반드시 Zookeeper 필요
        - Kafka 2.8~: KRaft 모드 (Zookeeper 없이 운영) 지원
        - Kafka 3.x~: KRaft가 안정화되어 점차 기본 구성이 되고 있음



 ### Kafka 기본 동작 구조

```
+-----------+        +-----------------+        +-------------+
| Producer  | -----> |   Kafka Broker  | -----> |  Consumer   |
+-----------+        +-----------------+        +-------------+
                          |   ▲
                          |   |
                  +-------------------+
                  |      Topic        |
                  +-------------------+
                          |
         +----------------+----------------+
         |                |                |
   +-----------+    +-----------+    +-----------+
   |Partition 1|    |Partition 2|    |Partition 3|
   +-----------+    +-----------+    +-----------+
```

- Producer가 메시지를 Topic에 전송
- Topic은 여러 Partition으로 구성되어 Kafka Broker에 분산 저장
- Consumer가 Topic의 Partition에서 메시지를 읽음
- Broker는 여러 대로 구성된 Kafka Cluster의 일부로, 데이터 저장과 전달을 담당


## Apache Kafka 설치 
- 설치 환경
    - Platform : GCP VM Instance
    - OS : Ubuntu 20.04
    - IP : 192.168.1.100


### kafka 설치 
```sh
# Kafka Binary 설치용 디렉토리 생성
$ mkdir -p apache_kafka/binary
$ cd apache_kafka/binary

# Kafka Binary 파일 다운로드 
$ wget https://downloads.apache.org/kafka/4.0.0/kafka_2.13-4.0.0.tgz
$ tar -xvzf kafka_2.13-4.0.0.tgz
$ cd kafka_2.13-4.0.0

# 설치된 Kafka 버전 정상 확인
./bin/kafka-server-start.sh --version
[2025-05-19 13:35:32,656] INFO Registered kafka:type=kafka.Log4jController MBean (kafka.utils.Log4jControllerRegistration$)
4.0.0
```    

### 최초 설정 및 kafka 서버 실행

- `kafka-storage.sh format`
    - Apache Kafka의 KRaft 모드( Zookeeper 없이 동작하는 모드)에서 클러스터의 각 브로커가 사용할 로그 디렉터리를 초기화(포맷) 하는 데 사용
    - Kafka 클러스터를 처음 구축하거나, 로그 디렉터리를 새로 설정할 때 반드시 필요

- kafka-server-start.sh의 경우, nohup 백그라운드로 실행 

```sh
# Kafka Storage Format 진행
$ bin/kafka-storage.sh format -t $(bin/kafka-storage.sh random-uuid) -c config/server.properties  --standalone

#  Kafka 서버 실행 (nohup Background)
$ nohup bin/kafka-server-start.sh config/server.properties > logs/kafka-server.log 2>&1 &
```

## Kafka Topic 구성 및 게시/구독 테스트 

- 신규 Topic 생성 
```sh
$ bin/kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
Created topic test-topic.
```

- Producer 스크립트를 통해 test-topic에 메세지 게시
```sh
bin/kafka-console-producer.sh --topic test-topic --bootstrap-server localhost:9092
>test kafka message 1
>test kafka message 2
>test kafka message 3
```

- Consumer 스크립트를 통해 test-topic에 게시된 메세지 확인 
```sh
# --from-beginning : 해당 토픽의 메세지를 처음부터 표기
bin/kafka-console-consumer.sh --topic test-topic --from-beginning --bootstrap-server localhost:9092 
test kafka message 1
test kafka message 2
test kafka message 3
```
