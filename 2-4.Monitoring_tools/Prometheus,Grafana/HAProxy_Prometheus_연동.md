# HAProxy Prometheus 연동 


## HAProxy Stats 페이지 설정 
>vi /etc/haproxy/haproxy.cfg
```
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 10s
    stats auth [ID]:[pw]
```
- 수정 후 cfg파일이 vaild 상태인지 확인하고 재기동 할것!
    - haproxy -f /etc/haproxy/haproxy.cfg -c

## HAProxy_exporter 설치 
```
cd /usr/share
wget https://github.com/prometheus/haproxy_exporter/releases/download/v0.10.0/haproxy_exporter-0.10.0.linux-amd64.tar.gz
tar xvf haproxy_exporter-0.10.0.linux-amd64.tar.gz
```

## HAProxy_exporter 실행 
```
cd haproxy_exporter-0.10.0.linux-amd64

#백그라우드로 실행하기 
./haproxy_exporter --haproxy.scrape-uri="http://[Stats:ID]:[Stats_PW]@[HAProxy_IP]:8404/stats;csv" & 
```

## HAProxy_exporter 서비스 작성하여 실행 

### HAProxy_exporter 서비스 작성

> vi /etc/systemd/system/haproxy_exporter.service
```
[Unit]
Description=HAProxy Exporter for Prometheus
After=network.target

[Service]
User=haproxy_exporter
Group=haproxy_exporter
Type=simple
EnvironmentFile=/etc/default/haproxy_exporter
ExecStart=/usr/local/bin/haproxy_exporter --haproxy.scrape-uri=${HAPROXY_SCRAPE_URI}
Restart=always

[Install]
WantedBy=multi-user.target
```

### EnvironmentFile 작성
>vim /etc/default/haproxy_exporter
```
HAPROXY_SCRAPE_URI="http://[Stats:ID]:[Stats_PW]@[HAProxy_IP]:8404/stats;csv"
```

### 설정 적용 및 재시작 
```
systemctl daemon-reload
systemctl restart haproxy_exporter
systemctl status haproxy_exporter
```

## Prometheus yml파일 수정

> vi prometheus.yml
```
scrape_configs:
  - job_name: 'haproxy_exporter'
    static_configs:
      - targets: ['localhost:9101']
```

## Prometheus Grafana 재기동 
```
systemctl restart prometheus grafana-server
```

- Grafana Dashboard ID   
    - 2428