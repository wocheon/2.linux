# GCP Monitoring API Metrics Fetcher

이 Python 스크립트는 Google Cloud Monitoring API를 사용하여 특정 메트릭 데이터를 가져오고, 이를 CSV 파일로 저장하는 도구입니다.

---

## 스크립트 개요

### 주요 기능
- Google Cloud Monitoring API를 통해 메트릭 데이터를 가져옵니다.
- KST(한국 표준시)로 입력된 시간을 UTC로 변환하여 API와 호환되도록 처리합니다.
- 수집된 데이터를 CSV 파일로 저장합니다.

---

## 코드 스니펫

아래는 스크립트의 주요 코드입니다:

```python
import json
from google.cloud import monitoring_v3
import pandas as pd
import datetime
import pytz

def fetch_metrics(config_file):
    # 🔹 설정 파일 읽기
    with open(config_file, "r") as file:
        config = json.load(file)

    project_id = config["project_id"]
    metrics = config["metrics"]
    output_prefix = config.get("output_prefix", "metrics")

    # GCP API는 UTC 기준이므로 KST → UTC 변환
    kst = pytz.timezone("Asia/Seoul")
    utc = pytz.utc

    # 🔹 KST -> offset-aware datetime 객체로 변환
    start_time_kst = kst.localize(datetime.datetime.fromisoformat(config["start_time_kst"]))
    end_time_kst = kst.localize(datetime.datetime.fromisoformat(config["end_time_kst"]))

    # 🔹 Time offset 적용
    start_time_offset = config.get("start_time_offset", 0)  # 시작 시간 조정 (분 단위)
    end_time_offset = config.get("end_time_offset", 0)      # 종료 시간 조정 (분 단위)

    # 🔹 시작 시간과 종료 시간에 각각 오프셋 적용
    adjusted_start_time_kst = start_time_kst - datetime.timedelta(minutes=start_time_offset)
    adjusted_end_time_kst = end_time_kst - datetime.timedelta(minutes=end_time_offset)

    # KST → UTC 변환
    start_time_utc = adjusted_start_time_kst.astimezone(utc)
    end_time_utc = adjusted_end_time_kst.astimezone(utc)

    # 클라이언트 생성
    client = monitoring_v3.MetricServiceClient()

    # 데이터를 저장할 딕셔너리
    data_dict = {}

    # Config 파일에서 데이터 로드
    for metric in metrics:
        metric_type = metric["metric_type"]
        filter_template = metric["filter_template"]
        label_key = metric["label_key"]
```

---

## 요구사항

### 필수 라이브러리
스크립트를 실행하기 전에 아래 라이브러리를 설치해야 합니다:
- google-cloud-monitoring
- pandas
- pytz



설치는 아래 명령어를 사용하세요:
```bash
pip install google-cloud-monitoring pandas pytz
```

### GCP 인증
Google Cloud Monitoring API를 사용하려면 GCP 서비스 계정 키 파일이 필요합니다. 키 파일 경로를 환경 변수로 설정하세요:
```bash
set GOOGLE_APPLICATION_CREDENTIALS="path/to/your-service-account-key.json"
```

---

## 설정 파일 (config.json)

스크립트는 설정 파일을 통해 동작을 제어합니다. 설정 파일은 JSON 형식으로 작성하며, 아래와 같은 구조를 가집니다:

```json
{
    "project_id": "your-gcp-project-id",
    "metrics": [
        {
            "metric_type": "compute.googleapis.com/instance/cpu/utilization",
            "filter_template": "resource.type=\"gce_instance\" AND metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
            "label_key": "instance_id"
        }
    ],
    "start_time_kst": "2023-01-01T00:00:00",
    "end_time_kst": "2023-01-01T23:59:59",
    "start_time_offset": 0,
    "end_time_offset": 0,
    "output_prefix": "metrics_output"
}
```

---

## 실행 방법

1. 설정 파일 작성
   - 위의 예시를 참고하여 

config.json

 파일을 작성합니다.

2. 스크립트 실행
   - 아래 명령어를 사용하여 스크립트를 실행합니다:
   ```bash
   python gcloud_monitoring_api_multi.py config.json
   ```

3. 결과 확인
   - 스크립트 실행 후, 결과는 CSV 파일로 저장됩니다. 파일 이름은 

output_prefix

와 메트릭 유형에 따라 결정됩니다.

---

## 주의사항

- GCP 프로젝트에서 Monitoring API가 활성화되어 있어야 합니다.
- 서비스 계정에 필요한 권한(`roles/monitoring.viewer`)이 부여되어 있어야 합니다.
- 시간 범위가 너무 넓으면 데이터 수집 시간이 오래 걸릴 수 있습니다.

---

## Docker 이미지 구성 및 실행

이 스크립트를 Docker 컨테이너로 실행할 수 있도록 이미지를 구성하는 방법은 다음과 같습니다:

### Dockerfile 작성

아래와 같은 내용으로 `Dockerfile`을 작성합니다:

```dockerfile
# Python 베이스 이미지 사용
FROM python:3.9-slim

# 작업 디렉토리 설정
WORKDIR /app

# 필요한 파일 복사
COPY . /app

# 의존성 설치
RUN pip install --no-cache-dir google-cloud-monitoring pandas pytz

# 실행 명령어 설정
CMD ["python", "gcloud_monitoring_api_multi.py", "config.json"]
```

### Docker 이미지 빌드

`Dockerfile`이 있는 디렉토리에서 아래 명령어를 실행하여 이미지를 빌드합니다:

```bash
docker build -t gcp-monitoring-fetcher .
```

### Docker 컨테이너 실행

이미지 빌드 후, 아래 명령어를 사용하여 컨테이너를 실행합니다:

```bash
docker run --rm -v /path/to/config:/app/config -e GOOGLE_APPLICATION_CREDENTIALS="/app/config/your-service-account-key.json" gcp-monitoring-fetcher
```

- `/path/to/config`는 `config.json`과 서비스 계정 키 파일이 있는 로컬 디렉토리 경로로 바꿉니다.
- `your-service-account-key.json`은 서비스 계정 키 파일 이름으로 바꿉니다.

### 주의사항

- `config.json`과 서비스 계정 키 파일은 컨테이너 내부에서 접근 가능하도록 볼륨 마운트를 설정해야 합니다.
- GCP 인증을 위해 `GOOGLE_APPLICATION_CREDENTIALS` 환경 변수를 올바르게 설정해야 합니다.
- Docker가 설치되어 있어야 하며, Docker 데몬이 실행 중이어야 합니다.
- 컨테이너 실행 시 필요한 권한이 있는지 확인하세요.
- 이미지 크기를 줄이기 위해 `slim` 베이스 이미지를 사용했습니다.
- 추가적인 의존성이 있다면 `Dockerfile`에 `RUN pip install` 명령어를 수정하여 포함하세요.