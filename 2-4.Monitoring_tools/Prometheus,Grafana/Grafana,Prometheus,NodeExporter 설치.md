# Prometheus, Grafana, NodeExporter 설치

## Prometheus

* Prometheus 설치
```bash 
cd /root
wget https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz
tar zxvf prometheus-2.27.1.linux-amd64.tar.gz
```
</br>

* Prometheus 실행 테스트

```bash
cd prometheus-2.27.1.linux-amd64
 ./prometheus &
jobs
kill -15 %1
```
</br>

* Prometheus 서비스 등록 

>vi /etc/systemd/system/prometheus.service

```bash
[Unit]
Description=Prometheus

[Service]
ExecStart=/root/prometheus/prometheus
WorkingDirectory=/root/prometheus

[Install]
WantedBy=multi-user.target
```
</br>

* prometheus 실행
```bash
systemctl status prometheus
systemctl enable prometheus --now
```
</br>

* 대시보드 접속 
>http://외부IP:9000
</br>

---

## Grafana

* Grafana 설치
```bash
yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-10.0.2-1.x86_64.rpm
yum remove https://dl.grafana.com/enterprise/release/grafana-enterprise-10.0.2-1.x86_64.rpm
systemctl start grafana-server 
```
</br>


* Grafana 접속
	- URL : http://외부IP:3000 
	- ID/PW : admin/admin
</br>
 
* 접속후 DataSource 추가 
	- Administration > Data sources > Add new data source 
		- type : prometheus
		- URL : http://localhost:9090
	- save&test로 저장후 확인 
</br>
 
* Node Exporter 대시보드 import
  
[https://grafana.com/grafana/dashboards/1860](https://grafana.com/grafana/dashboards/1860)
copy ID to Clipboard 로 id 복사하여 import

$\textcolor{orange}{\textsf{* node 지정이 안되어있으면 N/A로만 보이므로 주의}}$ 

</br>

---

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