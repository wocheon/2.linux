# Gitea - 경량 git 서버 

## Gitea ?
- Go언어로 작성된 경량 git 서버 
- 저사양 서버 혹은 소규모 환경에서 사용시 사용 가능
- 설치/운영이 비교적 간단함



## Gitlab Vs Gitea

|특징|GitLab|Gitea|
|:-:|:-:|:-:|
|언어 및 구조      |  Ruby on Rails 기반, 복잡하고 무거움                        |  Go 언어 기반, 경량화되어 빠르고 가벼움            |
|주요 기능        |  내장 CI/CD, 보안 스캐닝, 이슈 관리, 코드 리뷰, Kubernetes 관리 포함  |  Git 호스팅, 이슈 트래킹, PR, 기본 코드 리뷰 기능 제공|
|리소스 사용       |  고성능 서버 필요, CPU 및 메모리 많이 사용                        |  저사양 서버에도 적합, 메모리·CPU 적게 사용         |
|사용자 규모       |  대규모 조직 및 수천 명 이상 지원 가능                            |  소규모 팀, 개인용에 적합                     |
|프로젝트 규모      |  수천 개 프로젝트 이상 대규모 관리 가능                            |  중소규모 프로젝트 적합                       |
|설치 및 관리      |  복잡, 유지보수에 시간이 더 필요                                |  설치·운영 간단, 빠르게 배포 가능                |
|라이선스         |  오픈소스 커뮤니티 에디션과 유료 엔터프라이즈 버전                       |  완전 무료 오픈소스 (MIT 라이선스)              |
|확장성 및 통합     |  DevOps 전면 지원, 자체 CI/CD 시스템, 보안 기능 내장              |  외부 CI 도구 연동 필요, 기본 기능에 집중          |
|인터페이스 반응성    |  무거워서 느릴 수 있음                                      |  가볍고 빠른 반응성                         |
|동시 접속 및 확장성  |  다중 사용자 대규모 동시 접속 지원, 클러스터링 가능                     |  중소 규모 사용자 동시 접속에 적합                |
|백업 및 복구      |  강력한 백업 시스템, 증분 백업 지원                              |  기본 백업 기능 제공                        |


### 어떤 환경에서 적합한가? 

|환경 유형|적합한 선택|이유|
|:-:|:-:|:-:|
|개인, 소규모 팀|gitea|가볍고 간단하게 구축 가능, 리소스 적음|
|중대형 조직, 엔터프라이즈|gitlab|풍부한 기능, 강력한 CI/CD 및 보안 기능, 확장성 우수|
|저사양 서버, 제한된 자원|gitea|리소스 소모 적고 빠른 반응 속도|
|DevOps 전면 지원, 자동화 필요|gitlab|완전한 DevOps 플랫폼, 자체 CI/CD, 보안 기능 포함|



## gitea 실행 방법 

### 직접 설치 (바이너리 설치)


- wget을 통한 다운로드 or 공식 홈페이지에서 직접 다운로드 
    - https://about.gitea.com/products/gitea/
```
wget -O gitea https://dl.gitea.com/gitea/1.24.6/gitea-1.24.6-linux-amd64
```

- 실행 권한 부여 
```
chmod +x gitea
```

- gitea 실행 
```
./gitea web
```

- 브라우저를 통해 페이지 접속후 설치 진행
    - http://localhost:3000/

### docker 

```sh
docker run -d --name gitea \
  -p 3000:3000 \
  -p 2222:22 \
  -v /your/local/gitea:/data \
  -e USER_UID=1000 \
  -e USER_GID=1000 \
  -e TZ=Asia/Seoul \
  gitea/gitea:latest
```

### docker-compose

```yaml
version: "3"
services:
  gitea:
    image: gitea/gitea:1.22.0
    container_name: gitea
    restart: unless-stopped
    environment:
      - TZ=Asia/Seoul
      - LANG=ko_KR.UTF-8
      - USER_UID=1000
      - USER_GID=1000
    volumes:
      - ./data:/data
      - ./localtime:/etc/localtime:ro
      - ./timezone:/etc/timezone:ro
    ports:
      - "3000:3000"  # 웹 UI
      - "2222:22"    # SSH 접속
```


## Gitea 도메인(https) 적용 방법 
- 설치 시 Gitea 기본 URL, Server Domain 지정 
    - Gitea 기본 URL : https://test-cicd.com/gitea/
    - Gitea 기본 URL : test-cicd.com