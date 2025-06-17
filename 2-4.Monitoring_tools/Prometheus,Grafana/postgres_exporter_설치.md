# PostgreSQL용 Prometheus Exporter 설치

## postgres_exporter
- https://github.com/prometheus-community/postgres_exporter


---

## ✅ 설치 요약

1. PostgreSQL에 **Monitoring 전용 계정** 생성  
2. `postgres_exporter` 바이너리 설치  
3. 시스템 서비스 등록 (`systemd`)  
4. Prometheus 설정에 exporter 추가

---

## 🔧 1. PostgreSQL에 전용 계정 생성

```sql
-- PostgreSQL 접속
psql -U postgres

-- 계정 생성
CREATE USER exporter WITH PASSWORD 'your_secure_password';

-- 최소 권한만 부여
GRANT CONNECT ON DATABASE your_db_name TO exporter;
GRANT USAGE ON SCHEMA public TO exporter;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO exporter;

-- stats 접근 허용 (PostgreSQL 설정에 따라 추가 필요할 수도 있음)
ALTER USER exporter SET SEARCH_PATH TO public;
```

---

##  2. `postgres_exporter` 설치 (리눅스 기준)

### 바이너리 파일을 통해 설치
```bash
# 최신 릴리스 확인 후 다운로드
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.15.0/postgres_exporter-0.15.0.linux-amd64.tar.gz
tar -xzf postgres_exporter-0.15.0.linux-amd64.tar.gz
cd postgres_exporter-0.15.0.linux-amd64
sudo mv postgres_exporter /usr/local/bin/
```

---

##  3. 환경 변수 설정
- postgres_exporter용 환경변수 파일 등록

> /etc/postgres_exporter.env


```dotenv
DATA_SOURCE_NAME="postgresql://exporter:your_secure_password@localhost:5432/your_db_name?sslmode=disable"
```

---

##  4. systemd 서비스로 등록

> /etc/systemd/system/postgres_exporter.service

```ini
[Unit]
Description=Prometheus PostgreSQL Exporter
After=network.target

[Service]
EnvironmentFile=/etc/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# 적용 및 시작
#sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable postgres_exporter
sudo systemctl start postgres_exporter
```

---

##  5. Prometheus에서 metrics 수집 설정

`prometheus.yml`에 다음과 같이 추가:

```yaml
  - job_name: 'postgres'
    static_configs:
      - targets: ['<VM_IP>:9187']
```
기본 포트 : `9187`