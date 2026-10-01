# Redmine 설치 - Docker

## Docker 설치 
## Centos7

### docker 공식 repo 추가 
```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### 설치가능한 도커 버전 확인
```bash
yum list docker-ce --showduplicates | sort -r
```

### docker 최신버전 설치 
```bash
yum install -y docker-ce.x86_64
```

### 버전확인 
```bash
$ docker --version

Docker version 24.0.5, build ced0996
```
## Docker-Compose 설치 
* docker compose 다운로드
```bash
curl  -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
* 권한 변경
```
chmod +x /usr/local/bin/docker-compose
```

* docker compose 버전 확인
```
docker-compose -v
```
## yaml 파일 작성 

> docker-compose.yml
```
version: '3.1'

services:

  redmine:
    image: redmine
    restart: always
    ports:
      - 80:3000
    environment:
      REDMINE_DB_MYSQL: db
      REDMINE_DB_PASSWORD: welcome1
      REDMINE_SECRET_KEY_BASE: supersecretkey

  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: welcome1
      MYSQL_DATABASE: redmine
```

## docker-compose 실행
```
docker-compose -f docker-compose.yml up -d
```

## 웹브라우저로 접속확인 
- redmin admin ID/PW
    - admin/admin