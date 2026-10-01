# Nginx Proxy SSL 적용 

## 개요 
- 로컬 환경에서 테스트용도로 사용할 도메인의 SSL 인증서를 생성 및 적용 
    - mkcert, openssl 사용
- 해당 인증서 발급기관을 신뢰하도록 하여 정상적으로 인증서를 사용가능하도록 설정 
- 기존 nginx proxy를 HTTPS로 사용하도록 변경     

## 자체 서명 SSL 인증서 만들기 

### OpenSSL 로 생성 

- 루트 CA 개인키 생성
```
openssl genrsa -out rootCA.key 2048
```

- 루트 CA 자체 서명 인증서 생성 
```sh
# 10년 유효
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.pem \
  -subj "/C=KR/ST=Seoul/L=Gangnam/O=MyOrg/OU=CA/CN=MyRootCA"
```

- 서버용 개인키 생성

```
openssl genrsa -out server.key 2048
```

- 서버 CSR 생성을 위한 config 파일 생성 (SAN 포함을 위해 config 파일 사용)
    - SAN(Subject Alternative Name)
        -  하나의 SSL/TLS 인증서가 여러 도메인 이름(hostname) 또는 IP 주소를 동시에 지원할 수 있도록 인증서에 포함하는 확장 필드
> server.csr.cnf
```
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[dn]
C  = KR
ST = Seoul
L  = Gangnam
O  = MyOrg
OU = Server Dept
CN = test-cicd.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = test-cicd.com
DNS.2 = nexus.test-cicd.com
```

- 서버 CSR 생성

```
openssl req -new -key server.key -out server.csr -config server.csr.cnf
```

- 루트 CA로 서버 인증서 서명을 위한 cnf 파일 생성 (SAN 포함)
> server.crt.cnf
```
[v3_ext]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = test-cicd.com
DNS.2 = nexus.test-cicd.com
```

- 인증서 서명
```
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt \
  -days 365 -sha256 -extfile server.crt.cnf -extensions v3_ext
```



### mkcert로 생성 
- mkcert 설치 
```sh
sudo apt install mkcert
```

- mkcert CA 설치 
 ```sh
mkcert -install
```

- mkcert CA pem 파일 위치 확인 
```sh
$ mkcert -CAROOT 
/home/ciw0707/.local/share/mkcert

$ ls -l /home/ciw0707/.local/share/mkcert
total 8
-r-------- 1 ciw0707 ciw0707 2488 Sep 23 09:31 rootCA-key.pem
-rw-r--r-- 1 ciw0707 ciw0707 1671 Sep 23 09:31 rootCA.pem
```



## 자체 서명 RootCA를 신뢰하는 인증기관으로 등록 

### 윈도우 환경

#### 인증서 관리자에 루트 CA 인증서 등록 

- 사용자 인증서 관리자 실행
    - Ctrl + R > certmgr.msc > `신뢰할수 있는 루트 인증기관` > 인증서 > 빈 공간에 우클릭 > 모든작업 > 가져오기 
        - 혹은 제어판 > `사용자 인증서 관리`
    
    - 필요시 pem -> crt 로 확장자를 변경해도 정상 동작

- 등록 방법
    - OpenSSL
        - 생성된 rootCA.pem 파일을 등록
    - mkcert
        - `mkcert -install` 로 만든 rootCA.pem 파일을 등록 


### 리눅스 환경
- OpenSSL
    - Ubuntu/Debian
    ```sh
    # RootCA 인증서를 시스템 인증서에 복사
    cp rootCA.pem /usr/local/share/ca-certificates/rootCA.crt

    # 인증서 갱신 명령 실행
    update-ca-certificates
    ```
    
    - RHEL/CentOS
    ```sh
    # RootCA 인증서를 시스템 인증서에 복사
    sudo cp rootCA.pem /etc/pki/ca-trust/source/anchors/rootCA.crt

    # 인증서 갱신 명령 실행
    update-ca-trust extract
    ```

- mkcert
    - mkcert -install 시 시스템 저장소에 자동 등록되므로 별도로 루트 CA인증서를 등록 필요 없음


## Nginx Proxy 설정 변경

### nginx.conf 파일 변경 
> nginx.conf
```
# 80번 포트 HTTP -> HTTPS 리다이렉트
server {
    listen 80;
    server_name nexus.test-cicd.com test-cicd.com;

    return 301 https://$host$request_uri;
}

# HTTPS 서버 설정
server {
    listen 443 ssl;
    server_name nexus.test-cicd.com test-cicd.com;

    #mkcert
    ssl_certificate     /etc/nginx/certs/test-cicd.com.pem;
    ssl_certificate_key /etc/nginx/certs/test-cicd.com-key.pem;

    #openssl
#    ssl_certificate     /etc/nginx/certs/server.crt;      # OpenSSL로 생성한 서버 인증서
#    ssl_certificate_key /etc/nginx/certs/server.key;      # 서버 개인키


    client_max_body_size 2G;

    # 서브도메인 nexus.test-cicd.com 루트 경로 프록시
    location / {
        proxy_pass http://nexus:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_request_buffering off;
        proxy_buffering off;
        proxy_set_header Connection "";
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }

    # 경로 기반 프록시 설정들 (클라이언트 요청 경로 기반 라우팅)
    # 옵션이 중복되면 오류 발생
    #client_max_body_size 500m;

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

    location /nexus/ {
        proxy_pass http://nexus:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect     default;
        rewrite ^/nexus(/.*)$ $1 break;
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

    location /nexus {
        return 301 /nexus/;
    }
}
```


### docker-compose.yml 변경
- 내부에서 자체 생성 RootCA 인증서를 신뢰하게끔 하기위해서는 RootCA 인증서를 등록하는 과정이 필요 
- gitlab 디렉토리의 경우, /etc/gitlab/trusted-certs 디렉토리에 인증서를 넣어야 webhook 가능

> docker-compose.yml

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
     # - '443:443' # Nginx Proxy HTTPS 사용을 위해 기존 443 포트 비활성화
      - '5005:5005'
      - '10022:22'
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/logs:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'
      - './rootca/mkcert/rootCA.pem:/usr/local/share/ca-certificates/mkcert_rootCA.crt'       # mkcert  RootCA
      - './rootca/openssl/rootCA.pem:/usr/local/share/ca-certificates/openssl_rootCA.crt'       # OpenSSL RootCA
      - './rootca/mkcert/rootCA.pem:/etc/gitlab/trusted-certs/mkcert_rootCA.crt'       #  mkcert RootCA
      - './rootca/openssl/rootCA.pem:/etc/gitlab/trusted-certs/openssl_rootCA.crt'      # OpenSSL RootCA
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
    ports:
      - "8080:8080"
    environment:
      - JENKINS_OPTS=--prefix=/jenkins
    volumes:
      - './jenkins/jenkins-data:/var/jenkins_home'
      - '/var/run/docker.sock:/var/run/docker.sock'
      - './rootca/mkcert/rootCA.pem:/usr/local/share/ca-certificates/mkcert_rootCA.crt'       # mkcert  RootCA
      - './rootca/openssl/rootCA.pem:/usr/local/share/ca-certificates/openssl_rootCA.crt'       # OpenSSL RootCA
    networks:
      - cicd-network
    extra_hosts:
      - "test-cicd.com:172.22.0.100"
      - "nexus.test-cicd.com:172.22.0.100"

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
      - './rootca/mkcert/rootCA.pem:/usr/local/share/ca-certificates/mkcert_rootCA.crt'       # mkcert  RootCA
      - './rootca/openssl/rootCA.pem:/usr/local/share/ca-certificates/openssl_rootCA.crt'       # OpenSSL RootCA
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
      - './rootca/mkcert/rootCA.pem:/usr/local/share/ca-certificates/mkcert_rootCA.crt'       # mkcert  RootCA
      - './rootca/openssl/rootCA.pem:/usr/local/share/ca-certificates/openssl_rootCA.crt'       # OpenSSL RootCA
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
      - './rootca/mkcert/rootCA.pem:/etc/ca-certificates/trust-source/anchors/mkcert_rootCA.crt'       # mkcert  RootCA
      - './rootca/openssl/rootCA.pem:/etc/ca-certificates/trust-source/anchors/openssl_rootCA.crt'      # OpenSSL RootCA
    restart: always
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
      - "443:443"
    volumes:
      - ./nginx_proxy_https/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      #- ./nginx_proxy_https/ssl_cert/mkcert:/etc/nginx/certs           # mkcert
      - ./nginx_proxy_https/ssl_cert/openssl/server:/etc/nginx/certs    # OpenSSL
      - './rootca/mkcert/rootCA.pem:/usr/local/share/ca-certificates/mkcert_rootCA.crt'       # mkcert  RootCA
      - './rootca/openssl/rootCA.pem:/usr/local/share/ca-certificates/openssl_rootCA.crt'       # OpenSSL RootCA

networks:
  cicd-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.22.0.0/16

```

- docker-compose 재실행 
```
docker-compose down 
docker-compose up --build -d
```

### Container 내 RootCA 인증서 반영
- Container에 volume을 통해 붙인 RootCA인증서는 별도 명령을 수행해야 업데이트됨
    - Debian/Ubuntu : `update-ca-certificates`
    - RHEL/CentOS : `update-ca-trust extract`
    - 시스템별로 명령이 다르므로 확인 후 수행 필요 

- jenkins, sonarqube 컨테이너는 Java Truststore에 인증서를 등록하는 작업이 필요
    - 미등록시 sonarqube scan 및 quality gate 동작시 오류 발생 
    - 등록 후, Container 재시작해야 정상 반영

- sonarqube 용 postgresdb에는 해당 명령이 없으며, 외부 통신이 필요하지 않으므로 작업 대상에서 제외

- 자동 업데이트용 스크립트 
> update-ca-certificates.sh
```bash
#!/bin/bash

# JAVA_HOME 지정 (별도 확인 필요)
JAVA_HOME='/opt/java/openjdk'

# 인증서 파일 선택
rootCA_crtfile='/usr/local/share/ca-certificates/openssl_rootCA.crt'
#rootCA_crtfile='/usr/local/share/ca-certificates/mkcert_rootCA.crt'

# 1. update-ca-trust , update-ca-certificates 로 신뢰하는 인증서 목록에 추가 
echo "# Update-ca"
for i in $(docker ps -a --format "{{.Names}}" | grep cicd)
do
        if [ $i == 'cicd-nexus' ]; then
                echo "* $i"
                docker exec -it --user root $i update-ca-trust extract
        elif [ $i == 'cicd-postgresdb' ]; then
                continue
        else
                echo "* $i"
                docker exec -it --user root $i update-ca-certificates
        fi
done

# 2. Jenkins, Sonarqube의 Java Truststore에 인증서 추가
echo "# keytool add"
for i in $(docker ps -a --format "{{.Names}}" | grep cicd)
do
        if [ $i == 'cicd-jenkins' ]; then
                echo "* $i"
                docker exec -it --user root $i keytool -importcert -alias sonarqube-rootca -file $rootCA_crtfile -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit

        elif [ $i == 'cicd-sonarqube' ]; then
                echo "* $i"
                docker exec -it --user root $i keytool -importcert -alias myrootca -file $rootCA_crtfile -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
        else
                continue
        fi
done

# 3. Jenkins, Sonarqube 컨테이너 재시작 
echo "# Restart Container"
read -p "* Restart Containers ?:" ans

if [ $ans == 'y' ] || [ $ans == 'Y' ];then
        docker restart cicd-jenkins
        docker restart cicd-sonarqube
fi
```


## 기존 Container 내 URL 설정 변경 
- Nginx-Proxy의 프로토콜이 HTTP -> HTTPS로 변경됨에 따라, 기존 서버내 http로 설정된 URL을 변경 필요 


### jenkins 
- jenkins 관리 > system
    - Jenkins Location
        - Jenkins URL 
    - SonarQube servers
        - Server URL
    - GitLab
        - GitLab connections
            - GitLab host URL

- pipeline 스크립트 
    - 기존 URL의 http를 https로 변경 
    - NEXUS_URL_PORT를  80 -> 443으로 변경

### gitlab
- Admin 영역 > 설정 > 일반 > 공개 범위 및 엑세스 설정 
    - HTTP(S)용 커스텀 Git 클론 URL 
        - http -> https 로 변경

- 기존 프로젝트 내 Webhook이 http를 사용하는 경우, https URL로 재생성 필요

- Admin 영역 > 응용 프로그램 
    - GitLab Web IDE (파일 수정 시 웹IDE 실행)
        - 콜백 URL : https://test-cicd.com/gitlab/-/ide/oauth_redirect
        - 범위 : api 

### sonarqube 

- Administration > Configuration > General Settings > Genral
    - Server base URL 
        - https -> htttps 

- Administration > Configuration > Webhooks > URL 
    - http -> https

### nexus
