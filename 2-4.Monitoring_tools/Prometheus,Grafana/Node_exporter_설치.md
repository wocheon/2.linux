## Node Exporter

* Node exporter 설치

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar zxvf node_exporter-1.6.1.linux-amd64.tar.gz
mv node_exporter-1.6.1.linux-amd64 node_exporter
```
</br>

* Node exporter 서비스 등록 
>vi /etc/systemd/system/node_exporter.service

```bash
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/share/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
```
</br>

* Node exporter 서비스 시작

 ```bash
systemctl enable node_exporter --now
systemctl status node_exporter
```
</br>

### Node_exporter 자동설치 스크립트
```bash
#!/bin/bash

cd /usr/share/
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar zxvf node_exporter-1.6.1.linux-amd64.tar.gz
mv node_exporter-1.6.1.linux-amd64 node_exporter

cat  << EOF >> /etc/systemd/system/node_exporter.service 
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/share/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF


systemctl enable node_exporter --now
systemctl status node_exporter
```


$\textcolor{orange}{\textsf{* 포트 변경 필요 시}}$
- 해당 내용의 node_exporter.service 의 [Service] 부분에 추가

```bash
Environment="NODE_EXPORTER_ARGS=--web.listen-address=\":9101\""
ExecStart=/usr/bin/node_exporter $NODE_EXPORTER_ARGS
```
</br>


* Node Exporter 포트 확인
```bash
netstat -tnlp
```
</br>

* prometheus.yml 파일 변경 

>vi prometheus.yml

```bash
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']


  - job_name: 'NodeExporter'
    static_configs:
    - targets: ['localhost:9100', '192.168.2.3:9100', '192.168.2.4:9100']
```
</br>

* Prometheus, Grafana 재시작
```bash
systemctl restart prometheus grafana-server
```


* 참고 - GCP상에 올라온 VM들 자동으로 검색하는 방법 
- yml 파일에서 다음과 같이 설정 
- gcloud 인증되어있어야 정상적으로 연결가능

```yaml
  - job_name: 'NodeExporter'
    gce_sd_configs:
      - project: test_project
        zone: asia-northeast3-a
        port: 9100
        filter: (name="dev-*" status = "RUNNING")  OR (name="stg-*" status = "RUNNING")
      - project: test_project
        zone: asia-northeast3-a
        port: 9100
        filter: (name="prd-*" status = "RUNNING")
```        

- relabel_configs로 hostname도 같이 수집하도록 추가
```yaml
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "GCE_vm"
    gce_sd_configs:
      - project: xxxxxx
        zone: asia-northeast3-a
        port: 9100
      - project: xxxxxx
        zone: asia-northeast3-b
        port: 9100
      - project: xxxxxx
        zone: asia-northeast3-c
        port: 9100
    relabel_configs:
      - source_labels: [__meta_gce_instance_name]
        target_label: hostname
```

        