# CI/CD Toolchain (Docker Compose)

## 개요 
- CI/CD 구성을 위한 각 요소를 docker-compose로 한번에 배포 가능하도록 구성 
    - 필요시 각 컨테이너 별로 분할하여 사용가능 
- Nginx Proxy를 통해 경로 기반 라우팅 구성
    - 로컬 환경 내 hosts 파일에 도메인 설정 후 사용


## 아키텍쳐 구성 
```
[Client]
   ↓
[Nginx Proxy / LB]
   ↓
[GitLab] → [Jenkins] → [SonarQube] ↔ [Postgresql]
                            ↓
                        [Nexus] 
```

- Nginx Proxy 또는 Load Balancer
    - 외부에서 들어오는 트래픽을 받아 각 서비스로 라우팅

- GitLab
    - 소스코드 저장, CI/CD 트리거 역할, 코드 리포지토리

- Jenkins
    - 빌드 및 배포 파이프라인 실행기, GitLab에서 트리거된 작업 수행

- SonarQube
    - 코드 품질 분석 서비스
    - Jenkins 빌드 시 소스 코드의 품질 분석을 수행
    - 분석결과에 따라 다음단계 진행 여부를 결정

- 데이터 저장소(PostgreSQL)
    - SonarQube에서 사용하는 DB

- Nexus
    - docker image, war, jar 등 아티팩트 용 저장소
    - 빌드 산출물(아티팩트) 저장소 역할, Jenkins 빌드 결과물 저장
    

## 로컬환경 도메인 및 경로기반 라우팅 설정

### /etc/hosts에 사용할 도메인 명을 설정 
- Docker Desktop 사용시  C:\Windows\System32\drivers\etc\hosts 파일 수정 (관리자권한 필요)    
    - `도메인에는 다음 문자 사용불가 ( DNS 프로토콜 표준 - RFC 1035 )`
        - 공백 및 띄어쓰기
        - 특수 문자: ! @ # $ % ^ & * ( ) + = { } [ ] | \ : ; " ' < > , ? / ~ 등
        - 밑줄(_)은 RFC에서는 사용 제한이나 일부 DNS 서버에서 허용하기도 함 (권장하지 않음)
        - 도메인 레이블(각 부분)의 길이는 최대 63자이며, 전체 도메인 길이는 255자 이내여야 함
        - 도메인 이름은 숫자로만 구성되면 안 됨 (최초 글자는 문자 또는 숫자 가능)
- Nexus의 경우, 클라이언트 호환성 문제 등으로 인해 경로 기반 도메인을 사용불가하므로 서브도메인 형태로 구성

 ```sh
 127.0.0.1 test-cicd.com         # 기본 도메인
 127.0.0.1 nexus.test-cicd.com   # Nexus 저장소용 도메인
 ```

### 경로 기반 라우팅 설정을 위한 컨테이너별 ENV 값 추가 
> docker-compose.yaml
```sh
  gitlab:
    ......
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://localhost/gitlab'
    ......

  jenkins:
    ......
    environment:
      - JENKINS_OPTS=--prefix=/jenkins
    ......

  sonarqube:
    ......
    environment:
      - SONAR_WEB_CONTEXT=/sonarqube      
```


### Nginx Proxy 구성용 conf 파일 구성 
> nginx_prxoy.conf
```sh
server {
    listen 80;
    client_max_body_size 500m; # git파일 업로드 시 413(Request Entity Too Large) 방지

    location /jenkins/ {
        proxy_pass http://jenkins:8080/jenkins/;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /gitlab/ {
        proxy_pass http://gitlab/gitlab/;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /sonarqube/ {
        proxy_pass http://sonarqube:9000/sonarqube/;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /jenkins {
        return 301 /jenkins/;
    }
    location /gitlab {
        return 301 /gitlab/;
    }
    location /sonarqube {
        return 301 /sonarqube/;
    }

}

server {    
    listen 80;
    server_name nexus.test-cicd.com;
    client_max_body_size 2G;    # 아티펙트 업로드 시 413(Request Entity Too Large) 방지

    location / {
        proxy_pass http://nexus:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 아티펙트 업로드 시 Timeout 방지용 설정
        proxy_http_version 1.1;
        proxy_request_buffering off;
        proxy_buffering off;
        proxy_set_header Connection "";
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
    
    location /nexus {
        return 301 /nexus/;
    }
}
```


## Docker-compose 실행 
>docker-compose.yml
```yml
version: '3.6'
services:
  gitlab:
    image: 'gitlab/gitlab-ce:latest'
    container_name: cicd-gitlab
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://localhost/gitlab'
    ports:
      - '8181:80'
      - '443:443'
      - '5005:5005'
      - '10022:22'
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/logs:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'
    shm_size: '256m'
    networks:
      - cicd-network
    extra_hosts:
      - "test-cicd.com:172.22.0.100"
      - "nexus.test-cicd.com:172.22.0.100"

  jenkins:
    build:
      context: ./jenkins
      dockerfile: dockerfile
    image: myjenkins:latest
    container_name: cicd-jenkins
    restart: always
    environment:
      - JENKINS_OPTS=--prefix=/jenkins
    volumes:
      - './jenkins/jenkins-data:/var/jenkins_home'
      - '/var/run/docker.sock:/var/run/docker.sock'
    networks:
      - cicd-network
    extra_hosts:
      - "test-cicd.com:172.22.0.100"
      - "nexus.test-cicd.com:172.22.0.100"

  nginx_proxy:
    image: nginx:latest
    container_name: cicd-nginx-proxy
    networks:
      cicd-network:
        ipv4_address: 172.22.0.100
    ports:
      - "80:80"
    volumes:
      - ./nginx_proxy/nginx.conf:/etc/nginx/conf.d/default.conf:ro

  sonarqube:
    image: sonarqube:latest
    container_name: cicd-sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://cicd-postgresdb:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar_password
      - SONAR_WEB_CONTEXT=/sonarqube
    depends_on:
      - postgresdb
    volumes:
      - ./sonarqube/sonarqube_data:/opt/sonarqube/data
    networks:
      - cicd-network
    extra_hosts:
      - "test-cicd.com:172.22.0.100"
      - "nexus.test-cicd.com:172.22.0.100"

  postgresdb:
    image: postgres:15
    container_name: cicd-postgresdb
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar_password
      POSTGRES_DB: sonar
    volumes:
      - ./sonarqube/postgres_data:/var/lib/postgresql/data
    networks:
      - cicd-network
    extra_hosts:
      - "test-cicd.com:172.22.0.100"
      - "nexus.test-cicd.com:172.22.0.100"

  nexus:
    image: sonatype/nexus3:latest
    container_name: cicd-nexus
    ports:
      - "8081:8081"
    volumes:
      - ./nexus/nexus-data:/opt/sonatype/sonatype-work
    restart: always
    networks:
      - cicd-network
    extra_hosts:
      - "test-cicd.com:172.22.0.100"
      - "nexus.test-cicd.com:172.22.0.100"


networks:
  cicd-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.22.0.0/16
```


> 디렉토리 및 권한 구성

```sh
mkdir CICD
cd CICD

mkdir -p ./gitlab/config
mkdir -p ./gitlab/logs
mkdir -p ./gitlab/data
mkdir -p ./jenkins/jenkins-data
mkdir -p ./sonarqube/sonarqube_data
mkdir -p ./sonarqube/postgres_data
mkdir -p ./nginx-proxy

mkdir -p ./nexus/nexus-data
chown -R 200:200 ./nexus/nexus-data
```


> 최종 디렉토리 구성
```
tree -L 2
├── docker-compose.yml
├── gitlab
│   ├── config
│   ├── data
│   ├── docker-compose.yml
│   └── logs
├── jenkins
│   ├── daemon.json
│   ├── dockerfile
│   └── jenkins-data
├── nexus
│   └── nexus-data
├── nginx_proxy
│   └── nginx.conf
└── sonarqube
    ├── postgres_data
    └── sonarqube_data
```


- 이미지 빌드 및 실행

```
docker compose up --build -d
 ✔ Container cicd-postgresdb   Running                                                                                                                 0.0s
 ✔ Container cicd-gitlab       Running                                                                                                                 0.0s
 ✔ Container cicd-jenkins      Running                                                                                                                 0.0s
 ✔ Container cicd-nginx-proxy  Running                                                                                                                 0.0s
 ✔ Container cicd-sonarqube    Running                                                                                                                 0.0s
 ✔ Container cicd-nexus        Running                                                                                                                 0.0s
```


## 페이지별 로그인 및 계정 생성 

### gitlab 
- root 계정 inital_password 확인
    - root/[inital_password] 로 로그인 후 PW 변경
        ```
        docker exec -it --user root cicd-gitlab cat /etc/gitlab/initial_root_password
        ```

- 설정 > 일반 > 공개 범위 및 액세스 설정 > HTTP(S)용 커스텀 Git 클론 URL 변경
    - `http://test-cicd.cim/gitlab`

- gitlab CI 미사용시 기존 설정 해제 
    - 설정 -> CI/CD -> 지속적 통합 및 배포
        - `모든 프로젝트에 대한 자동 DevOps 파이프라인 기본값으로 설정` 해제
        - `새 프로젝트에 대한 인스턴스 러너 활성화` 해제


### Jenkins 

- inital_password 확인 후 기본 Plugin 설치 진행
    ```
    docker exec -it --user root cicd-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    ```
- 설치 과정에서 admin 계정을 별도 설정하여 사용

### Sonarqube 
- admin/admin으로 최초 로그인시 PW 변경가능 

- 사용자 계정 생성 
    - Administration > Security > Users > Create User


### Nexus 

- admin계정 inital_password 확인하여 로그인
    - 로그인 후 PW 변경 가능
    ```
    docker exec -it --user root cicd-nexus cat /opt/sonatype/sonatype-work/nexus3/admin.password
    ```

- 사용자 계정 생성 
    - Settings > Security > Users > Create local User


## Jenkins - System 설정 

### Jenkins Docker Socket 연동 확인 
- Jenkins에서 로컬환경에 docker Container 배포를 위해 docker socket 파일을 volume으로 연동하였음
- Jenkins 컨테이너에서 `docker ps -a` 로 현재 로컬 환경의 컨테이너 목록이 보이는지 확인
    ```
    docker exec -it --user root cicd-jenkins docker ps -a
    ```

### Jenkins Plugin - 설치 대상
- Pipeline Graph Analysis
- Pipeline: Stage View
- Publish Over SSH
- GitLab
- SonarQube Scanner
- Sonar Quality Gates
- Maven Integration
- Pipeline Maven Integration


## Jenkins - Credentials, 서버 간 연동 설정


### Jenkins <> gitlab 연결용 Credential 생성 
- 생성된 gitlab 사용자 정보를 Credential로 저장
    - kind : Username with password
    - Username : ciw0707
    - Password : [Password]
    - ID : gitlab-credentials


### Jenkins <> Sonarqube 서버 연동 

- Sonarqube Access Token 생성 
    - 우측 상단 클릭 > My Account > Security > Generate Tokens
        - Name : sonarqube-wocheon-token
        - Type : User
        - Expries in : No expiration


- 해당 토큰 값을 Jenkins Credential로 생성 
    - Credential_id : sonarqube-token
    - Kind : Secret text


- Jenkins 관리 > System > SonarQube servers 
    - Name : `sonarqube`
    - Server URL : `http://test-cicd.com/sonarqube`
    - Server authentication token : `sonarqube-token`

### Jenkins <> nexus 연결용 Credential 생성 
- 생성된 nexus 사용자 정보를 Credential로 저장
    - kind : Username with password
    - Username : ciw0707
    - Password : [Password]
    - ID : nexus-credentials

### Jenkins Webhook 설정 
- Jenkins에 전달할 Webhook이 등록되어있지 않으면  Sonarqube Scanner 실행 후 Quailty Gate에서 Pending에서 넘어가지 못함
    - Sonarqube 검증 결과를 가져오지 못해서 발생

- Webhook 추가 방법 
    - Admin 계정으로 로그인 > Administration > Configuration > Webhooks
        - NAME : jenkins-webhook
        - URL : http://test-cicd.com/jenkins/sonarqube-webhook
        - SECRET : sonarqube-webhook-secret

jenkins-webhook

## Jenkins - Tools 설치

### Jenkins Tools Sonarqube Scanner 설치 
- Jenkins 관리 > Tools > SonarQube Scanner installations > Add SonarQube Scanner
    - Name : sonarqube_scanner
    - Install automatically : true 
    - Version : 자동 지정

### Jenkins Tools Maven 설치 
- Jenkins 관리 > Tools > Maven installations > Add Maven
    - Name : jenkins-maven
    - Install automatically : true 
    - Version : 자동 지정    


### Jenkins Tools 설치 실행 
- 설정된 Tools는 해당 Tool을 실행시에 설치가 진행되므로 미리 설치가 되도록 해당 Pipeline 실행 

```groovy
pipeline {
  agent any
  stages {
    stage('Check Tools') {
      steps {
        script {
          // Maven 확인 및 설치 경로 설정
          def mvnExists = sh(script: "command -v mvn >/dev/null 2>&1", returnStatus: true) == 0
          if (!mvnExists) {
            echo 'Maven not found, installing via Jenkins Tool...'
            def mvnHome = tool 'jenkins-maven'
            env.PATH = "${mvnHome}/bin:" + env.PATH
          } else {
            echo 'Maven already installed.'
          }
          
          // SonarQube Scanner 확인 및 설치 경로 설정
          def scannerExists = sh(script: "command -v sonar-scanner >/dev/null 2>&1", returnStatus: true) == 0
          if (!scannerExists) {
            echo 'SonarQube Scanner not found, installing via Jenkins Tool...'
            def scannerHome = tool 'sonarqube_scanner'
            env.PATH = "${scannerHome}/bin:" + env.PATH
          } else {
            echo 'SonarQube Scanner already installed.'
          }
        }
      }
    }
    stage('Build') {
      steps {
        sh 'mvn --version'
        sh 'sonar-scanner --version'
      }
    }
  }
}
```

- 실행 후 컨테이너 내부에서 설치 확인
```sh
jenkins@102a533b4c20:~/plugins$ ls -l /var/jenkins_home/tools/
total 8
drwxr-xr-x 3 jenkins jenkins 4096 Sep 18 02:20 hudson.plugins.sonar.SonarRunnerInstallation
drwxr-xr-x 3 jenkins jenkins 4096 Sep 18 02:19 hudson.tasks.Maven_MavenInstallation
```


## gitlab - jenkins 연동

### gitlab 
- 프로젝트(Repository) 생성
    - docker_build_test
        - docker 빌드용 프로젝트
    - docker_deploy_test
        - docker 배포용 프로젝트
    - war_build_test
        - WAR 빌드용 프로젝트
    - war_deploy_test
        - WAR 빌드용 프로젝트        
    - 프로젝트 생성 후 파일 업로드 완료 

### jenkins
- 신규 pipeline type Item 생성
    
    - docker_build_test
        - Pipeline 
            - definition : Pipeline script from SCM
            - SCM : git 
            - Repository URL : http://test-cicd.com/gitlab/cicd/docker_build_test.git
            - Credential : gitlab-credentials
            - Branch Specifier :*/main
            - Script Path : Jenkinsfile

    - docker_deploy_test
        - Triggers
            - Build after other projects are built : docker_build_test
                - Trigger only if build is stable
        - Pipeline 
            - definition : Pipeline script from SCM
            - SCM : git 
            - Repository URL : http://test-cicd.com/gitlab/cicd/docker_deploy_test.git
            - Credential : gitlab-credentials
            - Branch Specifier :*/main
            - Script Path : Jenkinsfile


    - war_build_test 
        - Pipeline 
            - definition : Pipeline script from SCM
            - SCM : git 
            - Repository URL : http://test-cicd.com/gitlab/cicd/war_build_test.git
            - Credential : gitlab-credentials
            - Branch Specifier :*/main
            - Script Path : Jenkinsfile

    - war_deploy_test
        - Triggers
            - Build after other projects are built : war_build_test
                - Trigger only if build is stable
        - Pipeline 
            - definition : Pipeline script from SCM
            - SCM : git 
            - Repository URL : http://test-cicd.com/gitlab/cicd/war_deploy_test.git
            - Credential : gitlab-credentials
            - Branch Specifier :*/main
            - Script Path : Jenkinsfile



- 필요시 webhook 연동도 수행 
    - gitlab 프로젝트 선택 > 설정 > Webhooks에서 추가 

- `Invaild url given` 오류 발생 시 확인 사항 
    - Jenkins Webhook 주소 등록시 `Invaild url given` 하는 경우 다음 gitlab 설정 
    확인
    - admin -> 설정 -> 네트워크 -> 아웃바운드 요청 
        - `Webhook 및 통합에서 로컬 네트워크에 대한 요청 허용` 체크 확인
        - `후크 및 통합이 액세스할 수 있는 로컬 IP 주소 및 도메인 이름` 에 test-cicd.com 추가

## gitlab - Sonarqube 연동
- 필요시 gitlab 프로젝트를 미리 Import해두고 사용가능 
    - 만약 없는 프로젝트 ID를 대상으로 Scanner를 실행하면 자동으로 프로젝트가 생성됨

- Gitlab 프로젝트 연동 설정
    - Configuration name : gitlab-config
    - GitLab API URL : http://test_cicd.com/gitlab/api/v4
    - Personal Access Token : 연동할 프로젝트가 존재하는 계정의 Personal Access Token

- 위 설정 후 gitlab프로젝트를 가져와서 maven 등으로 Scan작업이 가능


## Nexus 내 docker repository 생성
- Nexus에서 Docker 이미지를 저장가능한 Registry를 생성
    - Settings > Repository > Repositories > Create repository
        - Recipe : docker (hosted)
        - Name : docker-hosted
        - Online : True
        - Repository Connectors : Path based routing


## CI/CD Pipeline #1 - Docker Build 