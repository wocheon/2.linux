# Prometheus 리로드 옵션 설정 방법 

## 개요 
- 기존 Prometheus 서비스는 yml파일을 변경한 뒤 재기동(restart) 가 필요 
- 특정 옵션을 추가하여 yml파일 설정 변경 후에 reload 할수있도록 설정


### Prometheus 서비스 변경
- ExecStart 에 --web.enable-lifecycle를 추가 후 재시작작
```
[Unit]
Description=Prometheus Server
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/share/prometheus-2.44.0.linux-amd64/prometheus --config.file=/usr/share/prometheus-2.44.0.linux-amd64/prometheus.yml --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
```

- daemon-reload 및 서비스 재시작

```
systemctl deamon-reload
# 설정한 알림 오류가 발생하지 않도록 grafana도 같이 재시작
systemctl restart prometheus grafana-server 
```


### 설정 리로드 테스트
- yml파일 설정 변경 후 curl 명령으로 리로드 구문 실행

```
curl -X POST http://localhost:9090/-/reload
```