# DCGM_Exporter - GCP Ops Agent 연동 
- google-cloud-ops-agent 에서 Prometheus 메트릭을 수집하여 GCP Monitoring으로 전송할수 있도록 연동
- 연동된 메트릭 정보를 통해 GCP 콘솔내에서 현재 GPU 관련 정보를 확인 가능

## DCGM_Exporter 설치 
- DCGM_Exporter의 경우 Docker를 사용하여 Container로 실행

### 1. Docker 설치 
- Docker가 설치되지않은 경우 Docker 설치 진행 
```
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
```
### 2. DCGM_Exporter 실행 
- 서비스를 생성하지 않고 단일 컨테이너로 실행하는 경우 다음과 같이 진행 
```
$ docker run --gpus all -rm -p 9400:9400 --name dcgm_exporter nvcr.io/nvidia/k8s/dcgm-exporter:3.3.6-3.4.2-ubuntu20.04
```

### 3. DCGM_Exporter 서비스 구성 및 실행 
- DCGM_Exporter를 서비스 형태로 구성하는 경우 다음과 같이 구성

> vim /etc/systmed/system/dcgm-exporter.service
```
[Unit]
Description=NVIDIA DCGM Exporter
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run --gpus all -rm -p 9400:9400 --name dcgm_exporter nvcr.io/nvidia/k8s/dcgm-exporter:3.3.6-3.4.2-ubuntu20.04
ExecStop=/usr/bin/docker stop dcgm_exporter
ExecStopPost=/usr/bin/docker rm dcgm_exporter
TimeoutSec=30

[Install]
WantedBy=multi-user.target
```

- Daemon Reload 및 DCGM_Exporter 기동
```
systemctl daemon-reload
systemctl enable dcgm-exporter.service --now
```


## google-cloud-ops-agent - Prometheus 연동 

### 1. **Ops Agent 상태 확인**
- Ops Agent가 정상적으로 실행 중인지 확인
```bash
systemctl status google-cloud-ops-agent
```

### 2. **Ops Agent 구성 확인**
- Prometheus Receiver 설정 변경
> vim /etc/google-cloud-ops-agent/config.yaml
```yaml
metrics:
  receivers:
    prometheus:
      type: prometheus
      config:
        scrape_configs:
          - job_name: 'dcgm-exporter'
            static_configs:
              - targets: ['localhost:9400']  # DCGM Exporter 엔드포인트
  service:
    pipelines:
      default_pipeline:
        receivers: [prometheus]
```

- 수정 후 Ops Agent 재시작
```bash
sudo service google-cloud-ops-agent restart
```

---

### 3. **Prometheus 메트릭 수집 상태 확인**
- Ops Agent가 Prometheus 메트릭을 올바르게 수집하고 있는지 확인

1. **Prometheus 메트릭 엔드포인트 확인**
   - DCGM Exporter 메트릭이 제공 여부 확인
   ```bash
   curl http://localhost:9400/metrics
   ```
   - GPU 메트릭 데이터 예시
   ```
   # HELP DCGM_FI_DEV_GPU_UTIL GPU utilization
   DCGM_FI_DEV_GPU_UTIL{gpu="0"} 45
   ```

2. **Ops Agent의 Prometheus 수집 상태 확인**
   - Ops Agent가 Prometheus 메트릭 전송에 실패하는 경우 로그에 오류 기록됨
   ```bash
   sudo journalctl -u google-cloud-ops-agent | grep prometheus
   ```

---

### 4. **GCP Monitoring에서 메트릭 확인**
- GCP 콘솔에서 측정항목 탐색기에 `Prometheus Target` 리소스 나오는지 확인
- 해당 메트릭을 사용하여 GCP 콘솔상에서 GPU 모니터링 가능
   

