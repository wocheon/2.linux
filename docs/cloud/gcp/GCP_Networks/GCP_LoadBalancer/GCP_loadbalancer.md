# GCP 부하분산 - https 리디렉션 및 URL map 설정

## URL MAP 
- HAProxy의 ACL에 해당하는 기능
- URL map에 구성된 규칙에 따라 들어오는 요청을 다른 대상으로 라우팅 해주는 기능

## 개요
1. HTTP 상에서 URL MAP 동작 확인
    - 인스턴스 생성 및 인스턴스 그룹 형성
    - 애플리케이션 부하 분산기(HTTP/S) 생성
    - Cloud DNS 설정
    - http 접속 확인

2. HTTPS로 프로토콜 변경 및 SSL 인증서 설정 
    - GCP 도메인 및 DNS 설정
    - http-https 리다이렉션 설정 
    - GCP 인증서를 통해 SSL 설정    
    - GCP 부하분산기를 이용하여 도메인별로 포워딩 룰을 설정 

3. Sub 도메인 (CNAME) 추가 및 URL MAP 변경 
    - 서브도메인 포함하여 SSL 인증서를 재발급
    - URL MAP에 서브도메인 규칙 적용 후 확인

## 기본 토폴로지 
```
                 __ https://testdomainname.info/web1/* ==> webserver1
                |
user ---GCP LB---
                |__ https://testdomainname.info/web2/* ==> webserver2
```

## HTTP 상에서 URL MAP 동작 확인

### 1. 인스턴스 생성 및 인스턴스 그룹 형성

 - VM webserver1 ,webserver2 를 생성 후 httpd 설치 
    - CentOS 기준 
    - 방화벽에서 80포트 접속 허용 규칙 생성

```
yum install -y httpd 
systemctl enable httpd --now
```

- 인스턴스 그룹에서 Unmanaged 그룹으로 각 VM별로 인스턴스 그룹을 생성 
    - webserver1 -> instance-group1
    - webserver2 -> instance-group2


### 2. 애플리케이션 부하 분산기(HTTP/S) 생성

- URL 맵은 다음에서만 사용이 가능

    - 전역 외부 애플리케이션 부하 분산기
    - 기본 애플리케이션 부하 분산기
    - 리전 외부 애플리케이션 부하 분산기
    - 리전 간 내부 애플리케이션 부하 분산기
    - 리전별 내부 애플리케이션 부하 분산기
    - Traffic Director

#### 애플리케이션 부하 분산기 생성
- 기본 선택 옵션
    - 인터넷에서 VM 또는 서버리스 서비스로
    - 기본 애플리케이션 부하 분산기

- 프론트엔드 구성 
    - 이름 : front_1
    - 프로토콜 : HTTP
    - 네트워크 서비스 계층 : 표준
    - IP address : front_1 (신규 생성후 예약)
    - 포트 : 80

- 백엔드 구성 
    - 백엔드 서비스를 생성 후 추가 
        - instance-group1, instance-group2를 사용하여 각각 web1,web2 서비스 생성 
            - 포트: 80 , Cloud CDN X , 나머지 기본 설정

- 호스트 및 경로 규칙
    - 모드 : 단순한 호스트 및 경로 규칙
    - 호스트 및 경로 규칙
        - 호스트2 : testdomainname.info , 경로2 : /web1/* , 백엔드 : web1 
        - 호스트3 : testdomainname.info , 경로3 : /web2/* , 백엔드 : web2

### Cloud DNS 설정 
- testdomainname.info의 A 레코드를 변경 
    - 프론트엔드의 IP로 설정 (front_1)

### http 접속 확인 
- web1, web2 별로 다른 서버로 리다이렉션되는지 확인 
    - 적용까지 어느정도 시간이 소요


## HTTPS로 프로토콜 변경 및 SSL 인증서 설정 

### SSL 인증서 생성 및 SSL 정책 설정 

#### GCP 인증서 생성
- 보안 -> 인증서 관리자 -> 기존 인증서 > SSL인증서 만들기
    - Google 관리 인증서 선택 후 도메인 등록 
        - 인증서명 : ssl-cert_1
        - CNAME은 각각 추가적으로 등록 필요
        - 프로비저닝 완료 후 사용가능

#### GCP SSL 정책 생성 
- 네트워크 -> SSL 정책 -> 정책만들기 
- ssl-lab A등급 발급 가능하도록 SSL 정책을 설정 
    - 정책명 : ssl-policy
    - 최소 TLS 버전 : 1.2
    - 프로필 : 최신

### 부하분산기 설정 변경 
- 프론트엔드 IP 및 포트 추가 
    - 이름 : front_2
    - 프로토콜 : HTTPS(HTTP/2 포함)
    - IP address : front_2 (신규 생성후 예약, 기존 front_1 할당해제 필요)
    - 포트 : 443
    - 인증서 : ssl-cert_1 (전 단계에서 생성한 인증서 선택)
    - SSL 정책 : ssl-policy (전 단계에서 생성한 SSL 정책)
    - HTTP-HTTPS 간 리디렉션 사용 설정

### DNS 레코드 변경 
- DNS A 레코드 값을 신규 생성한 IP로 변경 (front_2)

### https 접속 확인 
- web1, web2 별로 다른 서버로 리다이렉션되는지 확인 
    - 적용까지 어느정도 시간이 소요

- http로 접속시 https 로 리다이렌션되는지 확인


## 3. Sub 도메인 (CNAME) 추가 및 URL MAP 변경 

### DNS에 CNAME 추가 
- 신규 CNAME 레코드 추가 
    - web.testdomainname.info 
    - www.testdomainname.info 

### 신규 SSL 인증서 생성
- 기존 인증서가 사용중이므로 삭제가 불가
    - 신규 인증서 생성하여 대체 후 기존 인증서 삭제 조치

- 인증서명 : ssl_cert_2
- 생성모드 : Google 관리 인증서 만들기
- 도메인 
    - testdomainname.info 
    - web.testdomainname.info 
    - www.testdomainname.info 


### 서브도메인 URL MAP 규칙 추가 

### URL MAP 작동 확인

