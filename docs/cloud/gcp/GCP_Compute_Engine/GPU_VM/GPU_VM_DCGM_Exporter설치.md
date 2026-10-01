# GPU VM DCGM_Exporter 설치 

## 개요 
- GPU VM의 GPU 사용량을 모니터링 하기 위해 DCGM_Exporter를 설치 후 Prometheus와 연동을 진행 

- GKE에서는 Helm 차트를 통해서 설치했으나 일반 VM에서는 Docker를 통해 컨테이너 형태로 동작하게끔 설치 

- Ubuntu 기준

## Docker 설치 
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
```

- 설치 확인 
```
systemctl enable docker --now
docker -v
```

## Nvidia Container Toolkit 설치 
- 미설치시 Docker 컨테이너를 올렸을때 다음과 같이 오류가 발생하므로 꼭 설치해주고 컨테이너를 실행할것

```sh
$ docker run -it --rm --gpus all alpine /bin/sh
docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]].
```

-  Nvidia Container Toolkit 설치 
```sh
 distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
$ sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
```

- docker 재시작 
```
systemctl restart docker
```


### DCGM_Exporter 컨테이너 실행 
- 공식 Github
    - https://github.com/NVIDIA/dcgm-exporter
```sh
docker run -d --gpus all --rm -p 9400:9400 nvcr.io/nvidia/k8s/dcgm-exporter:3.3.6-3.4.2-ubuntu22.04
```

- 매트릭 확인 
```sh
$ curl localhost:9400/metrics
# HELP DCGM_FI_DEV_SM_CLOCK SM clock frequency (in MHz).
# TYPE DCGM_FI_DEV_SM_CLOCK gauge
# HELP DCGM_FI_DEV_MEM_CLOCK Memory clock frequency (in MHz).
# TYPE DCGM_FI_DEV_MEM_CLOCK gauge
# HELP DCGM_FI_DEV_MEMORY_TEMP Memory temperature (in C).
# TYPE DCGM_FI_DEV_MEMORY_TEMP gauge
...
DCGM_FI_DEV_SM_CLOCK{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 139
DCGM_FI_DEV_MEM_CLOCK{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 405
DCGM_FI_DEV_MEMORY_TEMP{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 9223372036854775794
...
```


### 서비스 형태로 변경하기 
- 관리 용이성을 위해 서비스 형태로 실행되도록 변경  
- 서비스로 변경 전 기존 컨테이너는 삭제 후 진행 

> vi /etc/systemd/system/dcgm-exporter.service
```
[Unit]
Description=DCGM Exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/dcgm-exporter
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

- 서비스 시작
```
sudo systemctl daemon-reload
sudo systemctl enable dcgm-exporter --now
```

- Prometheus 설정 추가 

> vi prometheus.yml

```sh
scrape_configs:
  - job_name: 'dcgm-exporter'
    static_configs:
      - targets: ['<YOUR_VM_IP>:9400']
```
