# GCP Pub/Sub + MIG 기반 비동기 Batch 처리 구조

## 개요

### 기본 아키텍쳐
```
Job Manager VM
   |
   |--(Job 발행)--> Pub/Sub Topic: batch_jobs (작업 큐, Autoscaler 신호용)
   |
   |--(상태 모니터링)--> Pub/Sub Topic: batch_jobs_status

MIG (Autoscaler: backlog 기반)
   |
   |-- VM Startup Script
          |
          |-- Pull 1 메시지 from batch_jobs
          |-- 즉시 ACK
          |-- Docker 컨테이너 실행 (Job)
          |-- Job 상태 publish to batch_jobs_status
          |-- Job 완료 후 VM shutdown
```


1. Job Manager VM에서 스크립트 등으로 프로세스 실행 명령
2. 해당 스크립트에서 Pub/Sub 토픽(작업큐) 에 메시지를 보냄
3. MIG는 Pub/Sub 토픽을 구독하여 Autoscaler Metric으로 사용
4. 작업 큐에 메시지가 들어오면 VM을 생성하여 프로세스 실행 
5. 실행 도중 새로운 작업 메시지가 들어오면 별도 VM을 생성해 프로세스 실행
6. 작업 완료 시 shutdown 명령등으로 VM 자동 종료


## 참고 - GCP Pub/Sub 구성 요소

- Publisher (게시자):
    - 메시지를 생성하여 *Topic(토픽)* 전달
    - 메시지 수신자는 고려하지 않음

- Topic (토픽):
    - 메시지를 받아들이는 중앙 허브 역할
    - 게시자가 보낸 메시지를 저장하고, 자신에게 연결된 모든 구독자에게 메시지를 전달

- Subscription (구독):
    - 특정 **Topic(토픽)** 에 연결되어 해당 토픽으로 전송된 메시지를 수신하겠다고 선언하는 객체
    - 각 구독은 고유하며, 토픽의 메시지 사본을 독립적으로 수신

- Consumer (소비자 또는 구독자 애플리케이션):
    - **Subscription(구독)** 에서 메시지를 가져가는 실제 애플리케이션 또는 서비스
    - gcloud pubsub subscriptions pull 명령어에서 메시지를 당겨오는 주체를 의미


## 구성 예시

### GCP Pub/Sub 구성 

#### Pub/Sub 토픽 구성 
```sh
# 작업 큐 토픽 (Autoscaler 신호용)
gcloud pubsub topics create batch_jobs
gcloud pubsub subscriptions create worker-sub --topic=batch_jobs --ack-deadline=600

# 상태 토픽 (Job 상태 전송용)
gcloud pubsub topics create batch_jobs_status
gcloud pubsub subscriptions create status-sub --topic=batch_jobs_status
```

#### Pub/Sub 동작 테스트 용 스크립트 

```bash
#!/bin/bash

# -----------------------------
# 3️⃣ 환경 변수 설정
# -----------------------------
PROJECT_ID=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
TOPIC="batch_jobs_status"
SUBSCRIPTION="status-sub"
JOB_ID="job-$(date +%Y%m%d%H%M%S)"

# -----------------------------
# 5️⃣ 상태 토픽에 STARTED 메시지 전송
# -----------------------------
gcloud pubsub topics publish $TOPIC \
    --project $PROJECT_ID \
    --message="{\"job_id\":\"$JOB_ID\",\"status\":\"TEST_MESSAGE_2\",\"vm_name\":\"$(hostname)\"}"


# -----------------------------
# 5️⃣ 상태 토픽에 STARTED 메시지 전송
# -----------------------------
gcloud pubsub subscriptions pull $SUBSCRIPTION --project $PROJECT_ID --auto-ack
```

- 실행 결과
```json
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬───────────────────┬──────────────┬────────────┬──────────────────┬────────────┐
│                                                                       DATA                                                                       │     MESSAGE_ID    │ ORDERING_KEY │ ATTRIBUTES │ DELIVERY_ATTEMPT │ ACK_STATUS │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼───────────────────┼──────────────┼────────────┼──────────────────┼────────────┤
│ {"job_id":"xxxxxxx-xxxx-xxxx-xxxx-xxxxx","status":"STARTED","vm_name":"instance-xxxxxx.asia-northeast3-a.c.test-project.internal"} │ xxxxxxxx │              │            │                  │ SUCCESS    │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴───────────────────┴──────────────┴────────────┴──────────────────┴────────────┘
```

<br> 

--- 

<br>

### Process 용 Docker 이미지 생성

#### Docker Image 구성 
> dockerfile
```
# 테스트용 Docker 이미지
FROM ubuntu:20.04

# 필요 패키지 설치
RUN apt-get update && apt-get install -y python3

# 환경 변수 JOB_DATA를 받아서 출력
CMD echo "Starting Job: $JOB_DATA" && \
    echo "Sleeping for 5 minutes to simulate workload..." && \
    sleep 300 && \
    echo "Job finished."
```

#### Docker 이미지 빌드 및 Artifact Registry에 Push
```
# GAR의 경로에 맞추어 이미지 태깅
docker build -t asia-northeast3-docker.pkg.dev/test-project/docker-image-repo/sleep_test:latest .

# GAR 저장소에 이미지 Push
docker push asia-northeast3-docker.pkg.dev/test-project/docker-image-repo/sleep_test:latest
```


<br> 

--- 

<br>



### Job 실행용 스크립트 구성 
- Job Manager에서 batch_jobs 토픽에 메시지를 게시하여 Job을 실행하는 스크립트 구성 

> pubsub_publish_topic_msg.sh
```bash
#!/bin/bash
set -e

# -----------------------------
# ✅ 설정값
# -----------------------------
PROJECT_ID=${PROJECT_ID:-$(gcloud config get-value project)}
TOPIC_ID=${TOPIC_ID:-batch_jobs}
PROCESS_TYPE=${1:-${PROCESS_TYPE:-sleep_test}}  # $1로 받고 null이면 기본값 사용
SLEEP_TIME=${SLEEP_TIME:-300}
VM_COUNT=${VM_COUNT:-1}

# -----------------------------
# ✅ 고유 Job ID 생성
# -----------------------------
JOB_ID=$(uuidgen)

# -----------------------------
# ✅ 메시지 생성 (JSON)
# -----------------------------
MESSAGE=$(cat <<EOF
{
  "job_id": "$JOB_ID",
  "process_type": "$PROCESS_TYPE",
  "sleep_time": $SLEEP_TIME,
  "vm_count": $VM_COUNT
}
EOF
)

# -----------------------------
# ✅ 메시지 게시
# -----------------------------
echo "📤 Publishing message to Pub/Sub..."
echo "$MESSAGE" | gcloud pubsub topics publish $TOPIC_ID \
  --project=$PROJECT_ID \
  --message="$(cat)" \
  >/dev/null

echo "✅ Job published successfully!"
echo "--------------------------------"
echo " Project ID : $PROJECT_ID"
echo " Topic ID   : $TOPIC_ID"
echo " Job ID     : $JOB_ID"
echo " Type       : $PROCESS_TYPE"
echo " Sleep Time : $SLEEP_TIME seconds"
echo " VM Count   : $VM_COUNT"
echo "--------------------------------"
```

<br> 

--- 

<br>



### MIG VM용 시작 스크립트 구성

- MIG에 신규 VM이 생성되었을때, batch_jobs 토픽에 연결된 worker-sub 구독 메시지를 READ
- batch_jobs_status 토픽에 STARTED 메시지 전송
- 메시지 내 process_type에 맞는 docker image를 사용하여 컨테이너 실행
- 컨테이너 실행 후 batch_jobs_status 토픽에 FINISHED 메시지 전송
- 모든 작업 완료 후 VM Shutdown

```sh
#!/bin/bash
set -e

# -----------------------------
# 1️⃣ 기본 패키지 설치
# -----------------------------
#apt-get update
#apt-get install -y docker.io jq curl

# -----------------------------
# 2️⃣ Artifact Registry 인증
# -----------------------------
# VM에 연결된 서비스 계정 사용
#gcloud auth configure-docker asia-northeast3-docker.pkg.dev

# -----------------------------
# 3️⃣ 환경 변수 설정
# -----------------------------
#PROJECT_ID=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
PROJECT_ID="test-project"
JOB_SUBSCRIPTION=${PUBSUB_SUBSCRIPTION:-worker-sub}
STATUS_TOPIC=${STATUS_TOPIC:-batch_jobs_status}
PROCESS_TYPE=${PROCESS_TYPE:-data_batch}
GAR_REPO=${GAR_REPO:-docker-image-repo}

# -----------------------------
# 4️⃣ Pub/Sub 메시지 pull + 즉시 ACK
# -----------------------------
# 메시지 1개 pull
RESPONSE=$(gcloud pubsub subscriptions pull $JOB_SUBSCRIPTION \
    --project $PROJECT_ID \
    --auto-ack \
    --limit=1 \
    --format=json)

if [ "$RESPONSE" = "[]" ] || [ -z "$RESPONSE" ]; then
    echo "No messages in the queue. Exiting."
    shutdown -h now
    exit 0
fi

# 메시지 내용 추출
MESSAGE=$(echo $RESPONSE | jq -r '.[0].message.data' | base64 --decode)
JOB_ID=$(echo $MESSAGE | jq -r '.job_id')
PROCESS_TYPE=$(echo $MESSAGE | jq -r '.process_type')

echo "Received Job: $JOB_ID"
echo "Process Type: $PROCESS_TYPE"

# -----------------------------
# 5️⃣ 상태 토픽에 STARTED 메시지 전송
# -----------------------------
gcloud pubsub topics publish $STATUS_TOPIC \
    --project $PROJECT_ID \
    --message="{\"job_id\":\"$JOB_ID\",\"status\":\"STARTED\",\"vm_name\":\"$(hostname)\"}"

# -----------------------------
# 6️⃣ Docker 컨테이너 실행 (Job 수행)
# -----------------------------
docker run --rm \
    -e "JOB_DATA=$MESSAGE" \
    asia-northeast3-docker.pkg.dev/$PROJECT_ID/$GAR_REPO/$PROCESS_TYPE:latest

# -----------------------------
# 7️⃣ 상태 토픽에 FINISHED 메시지 전송
# -----------------------------
gcloud pubsub topics publish $STATUS_TOPIC \
    --project $PROJECT_ID \
    --message="{\"job_id\":\"$JOB_ID\",\"status\":\"FINISHED\",\"vm_name\":\"$(hostname)\"}"

# -----------------------------
# 8️⃣ Job 완료 후 VM 종료
# -----------------------------
shutdown -h now
```


### Pub/Sub Topic 모니터링용 스크립트 

- requirements.txt
```
google-cloud-pubsub
```

- config.ini
```ini
[GCP]
project_id = test-project
#subscription_name = status-sub
subscription_name = batch_jobs_monitoring_sub
#credentials_path = /path/to/your/keyfile.json

[Logging]
log_file_path = /var/log/job_status.log
```


- pubsub-logger.py

```py
import logging
import os
import sys
import configparser  # configparser 모듈 임포트
from google.cloud import pubsub_v1
from concurrent.futures import TimeoutError

# --- 설정 파일 읽어오기 ---
config = configparser.ConfigParser()
config.read('config.ini') # config.ini 파일을 읽어옵니다.

# 설정값 변수에 할당
PROJECT_ID = config.get('GCP', 'project_id')
SUBSCRIPTION_NAME = config.get('GCP', 'subscription_name')
#CREDENTIALS_PATH = config.get('GCP', 'credentials_path')
LOG_FILE_PATH = config.get('Logging', 'log_file_path')

# 환경 변수로 인증 정보 설정 (Google Cloud 클라이언트가 자동으로 찾도록 함)
#os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = CREDENTIALS_PATH

# --- 로거 설정 ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE_PATH),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# --- Pub/Sub 클라이언트 설정 ---
subscriber = pubsub_v1.SubscriberClient()
status_sub_path = subscriber.subscription_path(PROJECT_ID, SUBSCRIPTION_NAME)

def status_callback(message):
    """메시지를 받아서 로그 파일에 기록합니다."""
    message_data = message.data.decode("utf-8")
    logger.info(f"Job Status: {message_data}")
    message.ack()

def run_subscriber():
    logger.info(f"리스닝 시작: {status_sub_path}")
    streaming_pull_future = subscriber.subscribe(status_sub_path, callback=status_callback)

    with subscriber:
        try:
            streaming_pull_future.result()
        except TimeoutError:
            streaming_pull_future.cancel()
            streaming_pull_future.result()

if __name__ == "__main__":
    run_subscriber()
```

## VM 이미지 및 템플릿 구성

### VM 이미지 구성 조건

- docker, jq, curl 설치 필요

- Artifact Registry 및 Pub/Sub 연동이 가능한 VM 필요 
    - `gcloud auth login --cred-file=xxx` 로 서비스 계정에 로그인 필요
    
- 시작 스크립트로 사용될 startup.sh을 포함


### 인스턴스 템플릿 구성 
- 위 이미지를 사용하는 인스턴스 템플릿을 미리 구성 
- Cloud API 범위 지정 필요 (Cloud Platform , Cloud Pub/Sub)


## MIG 생성 
- 구성한 인스턴스 템플릿으로 MIG 구성 

- Autoscaler Signal을 Cloud Pub/Sub 큐로 지정 


## 테스트 결과

- *`해당 구조는 사용 불가`*

- 주요 원인
	- MIG 메트릭으로 받아서 VM을 실행하는 속도가 너무 느림
	
	- 10분 이상 도는 프로세스의 경우 MIG autoscaler로 인해 강제 종료될 수 있음 
		- 미확인 메시지가 없는데 아직 VM이 있는상태로 10분이상 지속되면 Autoscaler가 불필요 대상으로 인식하여 삭제 조치 
	
	- 미확인 메시지가 있는데 아직 VM이 종료되지않았다면 새로운 VM이 안뜨고 그대로 유지되는 경우가 존재 