
# GITLAB 설치
## 테스트 환경

* GCP 클라우드에서 진행.
* 머신 유형 : e2-standard-2 (2 vcpu 8GB RAM)
* OS : CentsOS 7
* Disk : 20GB (기본 설정)

$\textcolor{orange}{\textsf{ * GITLAB 공식 홈페이지 제공 }}$ 
- 최소사양 4core 4GB RAM - 500명이상 사용가능

-	테스트 결과 CPU 사용량보다 RAM 사용량이 문제로 보여 2 core 8GB RAM으로 설정하였음 


## 서버에 직접 설치 
### 필수 종속성 설치

* postfix 설치 (메일 에이전트)

```bash
yum install -y postfix
systemctl enable postfix --now
```

### gitlab 설치
```bash
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
EXTERNAL_URL="localhost" yum install -y gitlab-ce
#외부 IP가 따로 존재하는 VM의 경우 localhost 대신 외부 IP사용
```

* 설치 후, 접속확인
  - URL : http://localhost
  - ID : root  
  - passwd : /etc/gitlab/initial_root_password 내용 복사하여 사용.
  - 신규 유저 생성 시 pending상태로 요청되며 root계정으로 접속후에 승인해야 정상적으로 등록.
  - project(repository) 생성후 테스트 진행.

  <br>

## GITLAB 설치 - docker-compose로 설치

### Docker 설치 
```bash
yum install -y docker 
systemctl enable docker --now 
docker --version
```

### Docker 버전 변경

* 기존 docker 버전(1.13.1)으로 진행시 <br>
$\textcolor{red}{\textsf{ ThreadError: can't create Thread: Operation not permitted }}$ 오류 발생하므로 <br>
 docker version 업그레이드 필요. (docker 20.10.10 이상) 


* 기존버전 확인 
```bash
$ docker --version
1.13.1
```
* 기존 컨테이너 및 이미지 삭제 
```bash
docker container rm  $(docker ps | grep -v CONTAINER | gawk '{print $1}') -f
docker image ls | grep -v TAG | gawk '{print $1":"$2}'
```

$\textcolor{orange}{\textsf{ * 안지워두면 꼬이는 경우가 생기므로 가능하면 지우고 진행. }}$ 


* yum update 및 기존 docker 삭제 
```bash
yum update
yum remove -y docker-common
rm -rf /var/lib/docker/
```

* docker 공식 repo 추가 
```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

* 설치가능한 도커 버전 확인
```bash
yum list docker-ce --showduplicates | sort -r
```
* docker 최신버전 설치 
```bash
yum install -y docker-ce.x86_64
```

* 설치후  Docker 버전확인 
```bash
$ docker --version
Docker version 24.0.5, build ced0996
```

### Docker-compose 설치 
```bash
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### Gitlab 설치용 docker-compose yml파일 작성 
>vi docker-compose.yml
```yaml
version: '3.6'
services:
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://localhost'
    ports:
      - '80:80'
      - '443:443'
      - '5005:5005' # Container Registry Port
      - '10022:22'
    volumes:
      - '$GITLAB_HOME/config:/etc/gitlab'
      - '$GITLAB_HOME/logs:/var/log/gitlab'
      - '$GITLAB_HOME/data:/var/opt/gitlab'
    shm_size: '256m'
```


### Docker-Compose 실행
```
docker-compse up -d 
```

### Docker-Compose 컨테이너 동작 확인
```
docker ps -a
```

### Docker-Compose 컨테이너 로그 조회 ( 컨테이너 올린후 3분정도 소요)
```
docker logs -f 
```

### Docker-Compose로 실행한 Gitlab Container 접속
```
docker exec -it gitlab-ce /bin/bash
```


### Docker-Compose로 실행한 Gitlab 접속
* 접속 URL : http://localhost
* ID : root  
* passwd : /root/gitlab/config/initial_root_password 확인
- 신규 유저 생성 시 pending상태로 요청되며 root계정으로 접속후에 승인해야 정상적으로 등록.
- project(repository) 생성후 테스트 진행.

<br> 

## Gitlab https 적용방법

### Gitlab용 Domain 구매
* Gitlab에 Https를 적용 시, 도메인 필요.
* GCP Domain 혹은 가비아 등에서 원하는 도메인을 구매. <br>
`GCP Domain이 비교적 적용하기 쉬움`

### Gitlab 설정파일 변경
> vi /etc/gitlab/gitlab.rb
```bash
external_url 'https://testdomainname.info'
...
################################################################################
# Let's Encrypt integration
################################################################################
 letsencrypt['enable'] = true
 letsencrypt['contact_emails'] = ['wocheon07@gmail.com'] # This should be an array of email addresses to add as contacts
 letsencrypt['key_size'] = 2048


#자동갱신 적용 필요 시 활성화
 letsencrypt['auto_renew'] = true
 letsencrypt['auto_renew_hour'] = 12
 letsencrypt['auto_renew_minute'] = 30 # Should be a number or cron expression, if specified.
 letsencrypt['auto_renew_day_of_month'] = "*/7"
 letsencrypt['auto_renew_log_directory'] = '/var/log/gitlab/lets-encrypt'
```

### 변경된 Gitlab 설정파일 적용
```bash
$ gitlab-ctl reconfigure
```

### Https 적용 확인
- /etc/gitlab/ssl 디렉토리 생성확인
- 브라우저에서 https로 접속 확인.<br>
 `(clone URL도 https가 적용됨)`

<br>

## gitlab ssl인증서 에러 발생시
>ex)
```bash
fatal: unable to access 'https://testdomainname.info/wocheon/docker_images.git/': SSL certificate problem: self-
signed certificate in certificate chain
```
* 해당 내용을 적용
```bash
git config --global http.sslVerify false
	or
export GIT_SSL_NO_VERIFY=0
```

<br>

## gitlab 상태 확인/ 실행 /중지 
```
# gitlab 시작
gitlab-ctl start

# gitlab 중지
gitlab-ctl stop

# gitlab 상태확인
gitlab-ctl status

# 설정파일 재설정 (중지 후 적용 시, 따로 재시작 필요)
gitlab-ctl reconfigure
```

<br>

## Github repository import 활성화 
* Gitlab은 기존 Github Repository를 Import하여 사용가능함.
* import 완료된 project에 발생하는 push, commit등은 github와 동기화되지는 않는다.

### Gitlab 세팅
- Admin Area > Settings > General > Visibility and access controls
- Import sources 에서 github 체크 후 save&change

### Github에서 token 발행 
* setting > Developer Settings >  Personal access tokens 에서 토큰발행
>ex)
```
ghp_xxxxxxxxxx
```

- Import project 에서 github 선택후 토큰 붙여넣기

### Gitlab 메뉴 한글설정
* 유저별로 설정에서 변경가능
* 프로젝트(리포지토리) 별로 설정에서 변경가능
* 번역률이 11%이므로 완벽하지는 않음...


<br>

## Gitlab Container Registry
* Docker Hub와 같은 이미지 저장소의 역할을 하는 기능.
* 사용 Port : 5050

* 사용법은  Docker허브와 동일하며, 이미지명은 프로젝트 명으로 고정.
* 버전 별로 구분하여 업로드 가능

- 기본적으로 https를 설정하면 자동으로 활성화되나 http로 연결하는 경우 세팅 변경필요


### Gitlab Container Registry - HTTP 로 설정 
- 설정파일 변경 
> vi gitlab.rb
```bash
 gitlab_rails['gitlab_default_projects_features_container_registry'] = true
 ...
 registry_external_url 'http://34.64.94.9:5050'
```
- 설정 적용
```
gitlab-ctl reconfigure
```

### docker login시 오류 발생
- HTTP 연결로 설정되었으므로 docker login 시 다음과 같은 오류 발생
```
$ docker login 34.64.75.69:5050
Username: root
Password:
Error response from daemon: Get "https://34.64.75.69:5050/v2/": http: server gave HTTP response to HTTPS client
```
- 해당 registry를 insecure-registry로 설정해야 정상 작동


> vi /etc/docker/daemon.json
```json
{

    "insecure-registries": ["34.64.75.69:5050"]

}
```

- docker 재기동 후 재 로그인
```
$ systemctl restart docker 

$docker login 34.64.75.69:5050
Username: root
Password:
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

```

### Gitlab Container Registry - HTTPS
- Gitlab 외부 주소를 HTTPS로 해둔경우 자동으로 기능이 활성화됨

#### Gitlab 연결 정보

* 도메인명 : testdomainname.info
* 사용자명 : wocheon
* 프로젝트명 : docker_images

<br>

#### Gitlab Container Registry에 Image Push

* Docker login으로 Container Registry에 연결
```bash
docker login testdomainname.info:5050
```

* Contianer Registry명으로 Docker Image Build
```bash
docker build -t testdomainname.info:5050/wocheon/docker_images .
```

* Contianer Registry에 Docker 이미지 push
```bash
docker push testdomainname.info:5050/wocheon/docker_images
```
<br>


#### Gitlab Container Registry에서 Image Pull

* Docker login으로 Container Registry에 연결
```bash
docker login testdomainname.info:5050
```

* Contianer Registry에 Docker 이미지 Pull
```bash
docker image pull testdomainname.info:5050/wocheon/docker_images
```

* 이미지 tag 변경 <br>
`편하게 쓰기위한 용도이며 필수 x`
```bash
docker tag -t testdomainname.info:5050/wocheon/docker_images webtest
```

* 가져온 이미지로 테스트 진행
```
docker container run -d -p 8080:80 --name test webtest
```