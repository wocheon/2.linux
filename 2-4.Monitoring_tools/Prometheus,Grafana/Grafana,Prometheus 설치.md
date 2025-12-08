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

