# Apache Kafka 사용 예제 #1 - Error 로그 확인 및 게시하여 Slack알림 발송

## 개요 
- Docker Image로 Producer/Consumer 이미지를 생성하여 사용

- 특정 어플리케이션의 Log 파일에 ERROR/CRITICAL/WARNING 으로 시작되는 로그가 기록되는 경우를 탐지하고 이를 Kafka Topic에 게시

- 게시된 Error 메세지를 확인하여, Slack 알림을 발송 

## Kafka Producer 컨테이너 구성 
### Producer 구성 - Producer 용 스크립트 파일 구성 

> kafka_producer.py
```py
import re
from kafka import KafkaProducer
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time
import datetime
import os

# 현재 timestamp 출력
timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print(f"[{timestamp}] ✅ kafka_producer started.")

# Kafka_Server_ip
kafka_server_ip=os.getenv("KAFKA_SERVER_IP")

# Kafka Producer 설정
producer = KafkaProducer(
    bootstrap_servers=f'{kafka_server_ip}:9092', # Kafka 브로커 주소
    value_serializer=lambda v: str(v).encode('utf-8')  # 메시지를 UTF-8로 인코딩
)

# Kafka에 메시지 게시하는 함수
def send_to_kafka(message, topic="errlog_check"):
    producer.send(topic, message)
    producer.flush()  # 메시지를 즉시 전송

# 필터링 함수: 로그에 특정 키워드가 포함된 경우만 처리
def should_send_to_kafka(message):
    keywords = ['ERROR', 'CRITICAL', 'WARNING']
    if any(keyword in message.upper() for keyword in keywords):
        return True
    return False

# 파일 시스템 이벤트 핸들러
class LogFileHandler(FileSystemEventHandler):
    def __init__(self, file_path):
        self.file_path = file_path

    def on_modified(self, event):
        if event.src_path == self.file_path:
            # 로그 파일에 새 줄이 추가되면 그 내용 읽기
            with open(self.file_path, 'r') as file:
                lines = file.readlines()
                # 파일의 마지막 라인만 체크 (중복 메시지 방지)
                last_line = lines[-1].strip()

                # 필터링 조건에 맞으면 Kafka에 메시지 전송
                if should_send_to_kafka(last_line):
                    print(f"[{timestamp}] Sending to Kafka: {last_line}")
                    send_to_kafka(last_line)

# 로그 파일 경로
log_file_path = "target_log/target_log.log"

# watchdog 설정: 특정 로그 파일을 모니터링
event_handler = LogFileHandler(log_file_path)
observer = Observer()
observer.schedule(event_handler, log_file_path, recursive=False)

# 모니터링 시작
observer.start()

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    observer.stop()

observer.join()
```

### Producer 구성 - pip 패키지 설치용 requirements.txt 파일 구성
> requirements.txt
```
kafka_python
watchdog
```

### Producer 구성 - dockerfile 구성 
> dockerfile 
```docker
FROM python:3.8-slim

WORKDIR /app

RUN mkdir /app/target_log

COPY kafka_producer.py .
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["python3", "-u", "kafka_producer.py"]
```


### Producer 구성 - docker image 빌드 및 Container 배포 

- Docker image 빌드 
```sh
$ docker build -t kafka_producer_test:1.0 .
```

- Docker Container 배포 
    - kafka server 는 Docker ENV로 지정 
    - 확인할 로그 파일은 -v옵션으로 컨테이너에 마운트하여 동기화
```sh
docker run --rm --network=host --name kafka_producer_test \
 -v /root/apache_kafka/kafka_slack_test/target_log/logfile.log:/app/target_log/target_log.log \
 -e KAFKA_SERVER_IP="192.168.1.100" \
 kafka_producer_test:1.0 > kafka_producer_log.log 2>&1 &
```


## Kafka Consumer 컨테이너 구성 
### Consumer 구성 - Consumer 용 스크립트 파일 구성 
> kafka_consumer.py
```py
from kafka import KafkaConsumer
import requests
import json
import re
import datetime
import os

# 현재 timestamp 출력
timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print(f"[{timestamp}] ✅ kafka_consumer started.")

# Kafka_Server_ip
kafka_server_ip=os.getenv("KAFKA_SERVER_IP")
# Slack Webhook URL
slack_webhook_url=os.getenv("SLACK_WEBHOOK_URL")

# Kafka Consumer 설정
consumer = KafkaConsumer(
    'errlog_check',  # 구독할 토픽 이름
    bootstrap_servers=f'{kafka_server_ip}:9092',  # Kafka 브로커 주소
    group_id='errlog_check',  # Consumer 그룹 ID
    auto_offset_reset='latest'  # 처음부터 메시지를 받으려면 'earliest', 최신 메시지만 받으려면 'latest'
)

# 메시지 필터링 함수 (예: "ERROR", "CRITICAL", "WARNING" 포함된 메시지만 Slack에 알림)
def should_send_to_slack(message):
    # 정규 표현식으로 "ERROR", "CRITICAL", "WARNING"이 포함된 메시지 찾기
    pattern = re.compile(r'^(ERROR|CRITICAL|WARNING).*', re.IGNORECASE)
    if pattern.match(message):
        return True
    return False

# Slack에 메시지 보내는 함수
def send_to_slack(message):
    payload = {
        "text": message
    }
    headers = {
        "Content-Type": "application/json"
    }
    response = requests.post(slack_webhook_url, data=json.dumps(payload), headers=headers)

    if response.status_code == 200:
        print(f"[{timestamp}] Successfully sent message to Slack")
    else:
        print(f"[{timestamp}] Failed to send message to Slack, status code: {response.status_code}")

# Kafka에서 메시지 읽기
for message in consumer:
    # 메시지를 바이트로 받음
    message_value = message.value.decode('utf-8')

    # 필터링 조건에 맞는 메시지만 처리
    if should_send_to_slack(message_value):
        print(f"[{timestamp}] Sending to Slack: {message_value}")
        send_to_slack(message_value)
```

### Consumer 구성 -  pip 패키지 설치용 requirements.txt 파일 구성
> requirements.txt
```
kafka_python
requests
```


### Consumer 구성 - dockerfile 구성 
> dockerfile 
```docker
FROM python:3.8-slim

WORKDIR /app

COPY kafka_consumer.py .
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["python3", "-u", "kafka_consumer.py"]
```

### Consumer 구성 - docker image 빌드 및 Container 배포 

- Docker image 빌드 
```sh
$ docker build -t kafka_consumer_test:1.0 .
```

- Docker Container 배포 
    - kafka server 는 Docker ENV로 지정 
    - Slack WebHook URL 또한 ENV로 지정 
```sh
docker run --rm --network=host --name kafka_consumer_test \
 -e KAFKA_SERVER_IP="192.168.1.100" \
 -e SLACK_WEBHOOK_URL="https://hooks.slack.com/services/xxxxx/xxxxxx/xxxxxxxxxxx" \
 kafka_consumer_test:1.0 > kafka_consumer_log.log 2>&1 &
```


## 정상 동작 테스트 

- 맨 앞의 문자열이 ERROR 인 경우에만 발송하는지 확인 

```bash
 echo "ERROR : test error Message : O" >> /root/apache_kafka/kafka_slack_test/target_log/logfile.log
 echo "ExRROR : test error Message : X" >> /root/apache_kafka/kafka_slack_test/target_log/logfile.log
 echo "ER1ROR : test error Message: X" >> /root/apache_kafka/kafka_slack_test/target_log/logfile.log
 ```

- 각 Container 별 로그 확인 

```
# Producer 
$ cat kafka_producer_log.log
[2025-05-19 05:34:19] ✅ kafka_producer started.
[2025-05-19 05:34:19] Sending to Kafka: ERROR : test error Message : O
[2025-05-19 05:34:19] Sending to Kafka: ExRROR : test error Message : X
[2025-05-19 05:34:19] Sending to Kafka: ER1ROR : test error Message: X

# Consumer
$ cat kafka_consumer_log.log
[2025-05-19 05:36:10] ✅ kafka_consumer started.
[2025-05-19 05:36:10] Sending to Slack: ERROR : test error Message : O
[2025-05-19 05:36:10] Successfully sent message to Slack
```


 - Slack 메시지 확인

 ![alt text](image.png)
 