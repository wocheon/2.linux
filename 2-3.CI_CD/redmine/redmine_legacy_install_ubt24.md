## 개요

* Ubuntu 24.04 LTS 환경에서 식별된 모든 아키텍처적 결함(권한 격리, 3000번 포트 바인딩, Passenger 기본 젬 충돌, DB 마이그레이션 이력 누락)을 교정한 최종 설치 파이프라인이다. Redmine 코어 마이그레이션 단계에 Slack 연동 플러그인(Slack Plugin)의 다운로드 및 데이터베이스 갱신 절차를 통합하여 단일 프로비저닝(Single Provisioning)으로 구성했다.

* **플러그인 마이그레이션 (Plugin Migration)**: 코어 시스템의 `db:migrate`와 별개로, 서드파티 플러그인이 요구하는 전용 데이터베이스 테이블이나 컬럼을 추가하기 위해 `rake redmine:plugins:migrate` 명령어를 실행하는 구조적 갱신 작업이다.
* **Webhook 기반 브로드캐스팅 (Webhook Broadcasting)**: Redmine 서버 내부의 이벤트(이슈 생성, 상태 변경 등)를 감지하여, 외부 서비스인 Slack의 Inbound Webhook URL로 JSON 형태의 HTTP POST 요청을 발송하는 단방향 이벤트 기반 아키텍처.
* 사전에 원본 서버에서 추출한 **전체 DB 덤프(`redmine_backup.sql`)**, **마이그레이션 이력 단독 덤프(`schema_migrations_only.sql`)**, 첨부파일(`redmine_files.tar.gz`)이 `/tmp/` 경로에 준비되어 있다고 가정한다. 모든 명령어는 명시된 권한 컨텍스트 내에서 순차적으로 실행한다.


## 설치 과정

**1단계: OS 의존성 및 전역 젬 충돌 해결 (`root` 권한)**

```bash
sudo apt update
sudo apt install -y build-essential mariadb-server libmariadb-dev \
    ruby-full ruby-dev ruby-bundler libapache2-mod-passenger apache2 \
    imagemagick libmagickwand-dev subversion git curl libyaml-dev

# Passenger의 Default Gem 로드 충돌 방지를 위한 전역 업데이트
sudo gem install bundler
sudo gem install base64 -v 0.3.0

```

**2단계: 격리 계정 생성 및 로컬 DB 복원 (`root` 권한)**

```bash
# 애플리케이션 전용 계정
sudo groupadd redmine
sudo useradd -r -g redmine -d /etc/redmine -s /bin/bash redmine

# 데이터베이스 구성 및 권한 부여
sudo mysql -u root -e "CREATE DATABASE redmine CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -e "CREATE USER 'redmine'@'localhost' IDENTIFIED BY '설정할비밀번호';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# 원본 데이터 적재 및 무결성 확보(마이그레이션 이력 덮어쓰기)
sudo mysql -u root redmine < /tmp/redmine_backup.sql
sudo mysql -u root redmine < /tmp/schema_migrations_only.sql

```

**3단계: 코어 시스템 및 Slack 플러그인 배치 (`root` 권한)**

```bash
sudo mkdir -p /etc/redmine
cd /etc/redmine
sudo wget https://www.redmine.org/releases/redmine-6.1.2.tar.gz
sudo tar -xvf redmine-6.1.2.tar.gz
sudo rm redmine-6.1.2.tar.gz

# 기존 첨부파일 이관
sudo tar -xzvf /tmp/redmine_files.tar.gz -C /etc/redmine/redmine-6.1.2/

# Slack 플러그인 다운로드 (가장 범용적인 Redmine 6.x 호환 Slack 플러그인 사용)
cd /etc/redmine/redmine-6.1.2/plugins
sudo git clone https://github.com/sciyoshi/redmine-slack.git redmine_slack

# 권한 일원화 및 정적 자원 퍼미션 정규화
sudo chown -R redmine:redmine /etc/redmine/redmine-6.1.2
sudo find /etc/redmine/redmine-6.1.2 -type d -exec chmod 755 {} \;
sudo find /etc/redmine/redmine-6.1.2 -type f -exec chmod 644 {} \;

```

**4단계: DB 연결 설정 (`root` 권한)**

```bash
cd /etc/redmine/redmine-6.1.2/config
sudo cp database.yml.example database.yml
sudo nano database.yml

```

```yaml
production:
  adapter: mysql2
  database: "redmine"
  host: "localhost"
  username: "redmine"
  password: "2단계에서설정한비밀번호"
  encoding: utf8mb4
  variables:
    tx_isolation: "READ-COMMITTED"

```

**5단계: 로컬 벤더링 및 마이그레이션 (`redmine` 계정 권한)**
반드시 `redmine` 계정으로 전환한다. 코어 마이그레이션과 플러그인 마이그레이션을 연속으로 수행한다.

```bash
sudo -u redmine -s /bin/bash
cd /etc/redmine/redmine-6.1.2

# 플러그인의 의존성까지 포함하여 로컬 벤더링 설치
bundle config set --local path 'vendor/bundle'
bundle config set --local without 'development test'
bundle install

# 보안 토큰 생성
bundle exec rake generate_secret_token

# 1. 코어 스키마 마이그레이션
HOME=/tmp RAILS_ENV=production bundle exec rake db:migrate

# 2. Slack 플러그인 스키마 마이그레이션
HOME=/tmp RAILS_ENV=production bundle exec rake redmine:plugins:migrate

# 포괄적 임시 파일 초기화
HOME=/tmp RAILS_ENV=production bundle exec rake tmp:clear
exit

```

**6단계: 3000 포트 바인딩 및 Apache 가상 호스트 연동 (`root` 권한)**

```bash
sudo nano /etc/apache2/ports.conf
# 파일 내부에 다음 라인 추가: Listen 3000

sudo nano /etc/apache2/sites-available/redmine.conf

```

```apache
<VirtualHost *:3000>
    ServerName redmine.example.com
    DocumentRoot /etc/redmine/redmine-6.1.2/public

    PassengerUser redmine
    PassengerGroup redmine
    PassengerAppEnv production

    ErrorLog ${APACHE_LOG_DIR}/redmine_error.log
    CustomLog ${APACHE_LOG_DIR}/redmine_access.log combined

    <Directory /etc/redmine/redmine-6.1.2/public>
        AllowOverride all
        Require all granted
        Options -MultiViews
    </Directory>
</VirtualHost>

```

```bash
# 기본 80포트 사이트 비활성화 및 Redmine 활성화
sudo a2dissite 000-default.conf
sudo a2ensite redmine.conf
sudo a2enmod passenger
sudo systemctl restart apache2
```

설치 완료 후 브라우저를 통해 `http://서버IP:3000`으로 접속하여 정상 구동을 확인한다. 이후 관리자 계정으로 로그인하여 `관리 > 플러그인 > Redmine Slack` 설정 페이지에서 발급받은 Slack Webhook URL을 입력한다.
