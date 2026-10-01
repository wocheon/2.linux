# Google-Cloud-Ops-Agent <> Prometheus 간 연동 

# 개요 
- GCP에서 제공하는 VM 내 모니터링 Agent인 Google-Cloud-Ops-Agent로 Prometheus 메트릭을 수집 가능하도록 설정
- 해당 메트릭을 통해 콘솔 내에서 모니터링이 가능하도록 구성 가능
- google-cloud-ops-agent의 최대 지원 버전이 낮아 GPU 관련 메트릭을 수집하지 못하는 경우에 주로 사용됨

## Google-Cloud-Ops-Agent 설치 

```
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
```

- 특정 버전 설치 필요 시 
```
sudo bash add-google-cloud-ops-agent-repo.sh --also-install \
  --version=2.*.*
```


- Agent 상태 확인 

```
sudo systemctl status google-cloud-ops-agent"*"
```


## Google-Cloud-Ops-Agent Config 파일 설정

- Metric 구분
    - hostmetrics 
        - 호스트 머신과 관련된 메트릭(CPU, 메모리, 디스크, 네트워크 사용량 등)을 수집
    - prometheus
        - Prometheus 익스포터(exporter)로부터 메트릭을 스크래핑하는 데 사용
        - dcgm-exporter처럼 Prometheus 엔드포인트를 통해 노출된 애플리케이션 수준의 메트릭을 수집

- /etc/google-cloud-ops-agent/config.yaml
```
metrics:
  receivers:
    hostmetrics:
      type: hostmetrics
      collection_interval: 10s
    prometheus:
      type: prometheus
      config:
        scrape_configs:
          - job_name: 'dcgm-exporter'
            static_configs:
              - targets: ['localhost:9400']
  service:
    pipelines:
      default_pipeline:
        receivers: [prometheus]
```        

## Google Cloud Console에서 메트릭 확인

1. GCP 콘솔에 접속
2. Monitoring > Metrics Explorer로 이동
3. 필터를 사용하여 `prometheus` 메트릭 검색
4. 수집된 메트릭을 기반으로 대시보드 생성 및 모니터링 설정