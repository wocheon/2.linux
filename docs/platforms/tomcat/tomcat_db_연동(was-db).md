# WAS-DB 연동 (Tomcat - MariaDB)

## WAS (Tomcat) 세팅
기본 OS는 Ubuntu 24.04 LTS, 대안은 Rocky Linux 9입니다. JDK 25 LTS + Tomcat 11 설치 및 서비스 구성은 [Apache-Tomcat 연동](tomcat_apache_연동%28web-was%29.md)의 WAS 절을 사용합니다. Tomcat 11은 Jakarta API 기반이므로 기존 `javax.*` WAR는 변경이 필요합니다.

## DB 설치
```bash
sudo apt update
sudo apt install -y mariadb-server
sudo systemctl enable --now mariadb
sudo mariadb-secure-installation
```

Rocky Linux 9: `sudo dnf install -y mariadb-server` 후 `sudo systemctl enable --now mariadb`.

### 테스트 DB 및 계정
```sql
CREATE DATABASE tomcat;
CREATE USER 'tomcat_app'@'127.0.0.1' IDENTIFIED BY 'REPLACE_WITH_TEST_PASSWORD';
GRANT SELECT ON tomcat.* TO 'tomcat_app'@'127.0.0.1';
CREATE TABLE tomcat.test (id varchar(20) primary key, pw varchar(20));
INSERT INTO tomcat.test VALUES ('admin', 'test-value');
```

## MariaDB JDBC 연결
[MariaDB Connector/J](https://mariadb.com/docs/connectors/mariadb-connector-j/)의 최신 호환 버전을 다운로드하여 `/opt/tomcat/lib/`에 복사하고 Tomcat을 재시작합니다. JDK의 `lib` 디렉터리에는 복사하지 않습니다.

`/etc/systemd/system/tomcat.service`의 `[Service]`에 테스트용 환경 파일을 지정합니다.
```ini
EnvironmentFile=/etc/tomcat/db.env
```

`/etc/tomcat/db.env`는 root만 읽도록 `chmod 600`으로 보호합니다. 저장소에 실제 비밀번호를 넣지 않습니다.
```ini
DB_URL=jdbc:mariadb://127.0.0.1:3306/tomcat
DB_USER=tomcat_app
DB_PASSWORD=REPLACE_WITH_TEST_PASSWORD
```

테스트 JSP는 [mariadb_contest.jsp](mariadb_contest.jsp)를 참고합니다. 테스트 후 JSP는 제거합니다.
