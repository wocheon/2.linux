# GCP Ops Agent 설치 및 파일 로그 수집

기본 환경: Ubuntu 24.04 LTS Compute Engine VM. Rocky Linux 9에서도 공식 설치 스크립트를 사용합니다. 기존 Fluentd 기반 Logging Agent 대신 신규 VM은 Ops Agent를 사용합니다.

## 준비
- VM 서비스 계정에 `roles/logging.logWriter`와 `roles/monitoring.metricWriter` 권한을 부여합니다.
- VM의 Google API 접근 범위와 네트워크 연결을 확인합니다. 서비스 계정 JSON 키를 VM에 복사하지 않습니다.

## 설치
```bash
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo systemctl status google-cloud-ops-agent
```

## 테스트 파일 로그
`/etc/google-cloud-ops-agent/config.yaml`:
```yaml
logging:
  receivers:
    app_file:
      type: files
      include_paths:
        - /var/log/my_app.log
  service:
    pipelines:
      app_pipeline:
        receivers: [app_file]
```

```bash
sudo systemctl restart google-cloud-ops-agent
echo 'ops-agent test' | sudo tee -a /var/log/my_app.log
sudo journalctl -u google-cloud-ops-agent -n 30 --no-pager
```

Cloud Logging 로그 탐색기에서 해당 VM의 `gce_instance` 리소스와 파일 로그를 확인합니다.

참고: [Ops Agent 설치](https://cloud.google.com/monitoring/agent/ops-agent/installation), [Ops Agent 구성](https://cloud.google.com/monitoring/agent/ops-agent/configuration)
