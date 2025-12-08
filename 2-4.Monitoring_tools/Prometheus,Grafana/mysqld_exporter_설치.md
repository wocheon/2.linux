# mysqld_exporter 설치 및 설정 가이드

## 개요
- mysqld_exporter, Grafana 설치 및 기본 설정 방법

---

## MariaDB 10.5 설치 (예시)
리포지토리 추가 및 설치:
```bash
cat << EOF >> /etc/yum.repos.d/MaraiDB.repo
# MariaDB 10.5 CentOS repository list
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

yum install -y MariaDB-server MariaDB-client
systemctl restart mysql
mysql_secure_installation  # root pw 예: welcome1
```

사용자 예제:
```sql
mysql -u root -pwelcome1
GRANT USAGE ON *.* TO dbtest_1@'%' IDENTIFIED BY 'welcome1';
GRANT USAGE ON *.* TO dbtest_2@'%' IDENTIFIED BY 'welcome1';
FLUSH PRIVILEGES;
EXIT;
```

---

## mysqld_exporter 설치 및 설정 (v0.14.0 예시)
```bash
cd /usr/share/
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.14.0/mysqld_exporter-0.14.0.linux-amd64.tar.gz
tar xzvf mysqld_exporter-0.14.0.linux-amd64.tar.gz
cd mysqld_exporter-0.14.0.linux-amd64
```

mysqld_exporter용 my.cnf (예시):
```ini
# mysqld_exporter.cnf (파일 위치: /usr/share/mysqld_exporter-0.14.0.linux-amd64/mysqld_exporter.cnf)
[client]
user=exporter
password=exporter_password
```

MySQL에서 exporter 계정 생성:
```sql
mysql -u root -pwelcome1
CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'exporter_password' WITH MAX_USER_CONNECTIONS 2;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

systemd 유닛:
```ini
# /etc/systemd/system/mysqld_exporter.service
[Unit]
Description=MySQL Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
Restart=always
ExecStart=/usr/share/mysqld_exporter-0.14.0.linux-amd64/mysqld_exporter \
--config.my-cnf /usr/share/mysqld_exporter-0.14.0.linux-amd64/mysqld_exporter.cnf \
--collect.global_status \
--collect.info_schema.innodb_metrics \
--collect.auto_increment.columns \
--collect.info_schema.processlist \
--collect.binlog_size \
--collect.info_schema.tablestats \
--collect.global_variables \
--collect.info_schema.query_response_time \
--collect.info_schema.userstats \
--collect.info_schema.tables \
--collect.perf_schema.tablelocks \
--collect.perf_schema.file_events \
--collect.perf_schema.eventswaits \
--collect.perf_schema.indexiowaits \
--collect.perf_schema.tableiowaits \
--collect.slave_status \
--web.listen-address=0.0.0.0:9104

[Install]
WantedBy=multi-user.target
```

서비스 적용:
```bash
systemctl daemon-reload
systemctl enable mysqld_exporter --now
systemctl status mysqld_exporter
```

---

## Prometheus 설정 (prometheus.yml 예시)
파일 위치: `/usr/share/prometheus-2.44.0.linux-amd64/prometheus.yml`
```yaml
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "mysqld-exporter"
    static_configs:
      - targets: ["192.168.1.101:9104", "192.168.1.102:9104"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["192.168.1.101:9100", "192.168.1.102:9100"]
```

Prometheus 재시작:
```bash
sudo systemctl restart prometheus.service
sudo systemctl status prometheus.service
```

---

## 포트 및 서비스 확인 예시
```bash
# 포트 확인 (node_exporter, mysqld_exporter)
netstat -tnlp | grep -e node_exporter -e mysqld_export
# 예: tcp6 0 0 :::9100 LISTEN .../node_exporter
# 예: tcp6 0 0 :::9104 LISTEN .../mysqld_exporter

# grafana
netstat -tlnp | grep grafana  # 일반적으로 3000 포트 LISTEN
```

---

## 간단한 주의사항 및 팁
- 서비스는 가급적 비root 사용자로 실행 권장(위 예시는 간편 설치용으로 root 사용).
- 방화벽(firewalld/iptables)에서 포트(9090, 9100, 9104, 3000 등)를 허용해야 외부에서 조회 가능.
- mysqld_exporter의 my.cnf는 권한 제한(600) 및 적절한 위치로 관리 권장.
- Prometheus 설정 변경 후 systemctl restart 필요.
- 프로덕션 환경에서는 exporter 및 Prometheus/Grafana 버전 정책과 보안(인증/네트워크 분리)을 검토할 것.

