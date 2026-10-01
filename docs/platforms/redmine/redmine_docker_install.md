# Redmine 설치 - Docker

> **테스트 문서:** Rocky Linux 9와 Compose v2 기준의 간단한 Redmine 테스트 구성입니다.

## Docker 설치
## Rocky Linux 9

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
docker compose version
```

## yaml 파일 작성 

> docker-compose.yml
```
services:

  redmine:
    image: redmine:7.0
    restart: always
    ports:
      - 80:3000
    environment:
      REDMINE_DB_MYSQL: db
      REDMINE_DB_PASSWORD: ${REDMINE_DB_PASSWORD:-redmine_test}
      REDMINE_SECRET_KEY_BASE: ${REDMINE_SECRET_KEY_BASE:-test_only_secret}

  db:
    image: mysql:8.4
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-mysql_test}
      MYSQL_DATABASE: redmine
```

## docker compose 실행
```
docker compose -f docker-compose.yml up -d
```

## 웹브라우저로 접속확인 
- redmin admin ID/PW
    - admin/admin