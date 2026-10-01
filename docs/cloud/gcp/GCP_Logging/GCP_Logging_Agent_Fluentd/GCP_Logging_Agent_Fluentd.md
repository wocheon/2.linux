# GCP 로깅 에이전트 Fluentd 구성 가이드

## 개요
- 이 문서는 Google Cloud Logging Agent와 Fluentd를 사용하여 로그를 수집하고 Google Cloud Logging에 전달하는 방법을 설명합니다.
- 설치, 구성, 인증 및 적용 확인 단계를 포함합니다.

## 사전 요구사항
- 결제가 활성화된 Google Cloud Platform (GCP) 프로젝트.
- 로깅을 구성할 수 있는 적절한 IAM 권한.
- Google Cloud Logging Agent를 설치할 VM 인스턴스 또는 서버.

## 서비스 계정 IAM 권한 부여
1. **서비스 계정 확인**  
    - VM 인스턴스에 연결된 서비스 계정을 확인합니다.  
    - 아래 명령어를 사용하여 서비스 계정 이메일을 확인합니다:
    ```bash
    gcloud compute instances describe INSTANCE_NAME --zone=ZONE --format="value(serviceAccounts.email)"
    ```
2. **IAM 역할 부여**  
    - 서비스 계정에 `roles/logging.logWriter` 역할을 부여합니다.  
    - 아래 명령어를 사용하여 권한을 추가합니다:
    ```bash
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
        --role="roles/logging.logWriter"
    ```

## google-cloud-logging-Agent 설치
1. **설치 스크립트 실행**  
    - GCP 공식 문서에 따라 설치 스크립트를 실행합니다.  
    - 아래 명령어를 순서대로 실행합니다:
    ```bash
    curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
    sudo bash add-logging-agent-repo.sh
    sudo apt-get update
    sudo apt-get install google-fluentd
    ```
2. **GCP 플러그인 설치**  
    - Fluentd에 필요한 GCP 플러그인을 설치합니다.  
    - 아래 명령어를 실행합니다:
    ```bash
    sudo apt-get install google-fluentd-catch-all-config
    ```

## google-cloud-logging-Agent 연동 (ADC)
1. **인증 설정**  
    - 서비스 계정 키 파일을 사용하는 경우, 환경 변수를 설정합니다.  
    - 아래 명령어를 사용하여 인증을 설정합니다:
    ```bash
    export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-service-account-key.json"
    ```
2. **ADC 확인**  
    - 인증이 올바르게 설정되었는지 확인합니다.  
    - 아래 명령어를 실행하여 액세스 토큰을 출력합니다:
    ```bash
    gcloud auth application-default print-access-token
    ```

## Fluentd 설정파일 변경
- Fluentd 구성 파일(예: `/etc/google-fluentd/google-fluentd.conf`)을 수정하여 로그 경로와 GCP 프로젝트 ID를 설정합니다.
- `YOUR_PROJECT_ID`를 실제 GCP 프로젝트 ID로 교체합니다.
    ```xml
    <source>
         @type tail
         path /var/log/my_app.log
         pos_file /var/log/google-fluentd/my_app.pos
         tag my_app
         format none
    </source>
    <match **>
         @type google_cloud
         project_id YOUR_PROJECT_ID
         log_name my_app_log
         resource type="global"
    </match>
    ```

## 적용 확인
1. **에이전트 시작**  
    - Google Cloud Logging Agent를 시작합니다.  
    - 아래 명령어를 실행합니다:
    ```bash
    sudo systemctl start google-fluentd
    ```
2. **상태 확인**  
    - 에이전트가 정상적으로 실행 중인지 확인합니다.  
    - 아래 명령어를 실행합니다:
    ```bash
    sudo systemctl status google-fluentd
    ```
3. **설정 변경 후 재시작**  
    - 구성 파일을 수정한 경우, 변경 사항을 적용하려면 에이전트를 재시작해야 합니다.  
    - 아래 명령어를 실행합니다:
    ```bash
    sudo systemctl restart google-fluentd
    ```
## 로그 확인
1. **로그 확인**  
- Google Cloud Console에서 로그가 수집되었는지 확인합니다.  
- 아래 단계를 따라 진행합니다:
    1. GCP 콘솔에서 **Logging** > **로그 탐색기**로 이동합니다.
    2. **리소스 유형**에서 로그를 수집한 VM 인스턴스를 선택합니다.
    3. **로그 이름**에서 `my_app_log`를 선택하여 로그 내용을 확인합니다.


2. **명령어로 확인**  
- `gcloud` 명령어를 사용하여 로그를 확인할 수도 있습니다:
    - `YOUR_PROJECT_ID`를 실제 GCP 프로젝트 ID로 교체합니다.
    ```bash
    gcloud logging read "resource.type=global AND logName=projects/YOUR_PROJECT_ID/logs/my_app_log" --limit 10
    ```
