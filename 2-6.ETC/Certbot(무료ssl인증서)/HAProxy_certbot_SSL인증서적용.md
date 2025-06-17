# HAProxy에서 certbot을 이용하여 SSL인증서 적용

## 기본 세팅
- firewalld ,selinux OFF
```bash
systemctl disable firewalld --now; setenforce 0;
```
<br>

- openssl, haproxy 설치
```bash
yum install -y curl wget haproxy openssl
```
<br>

- openssl 확인
```bash
openssl version
```
<br>

- haproxy 상태 확인
```
systemctl status haproxy
```
<br>

# HAProxy log 설정 

* 설정파일 수정

>vi /etc/rsyslog.d/49-haproxy.conf

```bash
$ModLoad imudp
$UDPServerAddress 127.0.0.1
$UDPServerRun 514

local0.* -/var/log/haproxy/haproxy_0.log
local1.* -/var/log/haproxy/haproxy_1.log
```
<br>

>vi /etc/rsyslog.conf
```bash
loacl0.none /var/log/messages 
```
<br>

* rsyslog 재시작
```bash
systemctl restart rsyslog
```
<br>


## Self Singned SSL 인증서 발급 
```bash
mkdir /etc/haproxy/certs/; cd /etc/haproxy/certs/    
openssl genrsa -out rootCA.key 2048    
openssl req -new -key rootCA.key -out rootCA.csr    
openssl x509 -req -in rootCA.csr -signkey rootCA.key  -out rootCA.crt
cat rootCA.key rootCA.crt > rootCA.pem
```
$\textcolor{orange}{\textsf{* 해당 방법으로 인증서 발급시, 유효하지 않은 인증서로 나옴}}$ 
<br>
<br>

## Certbot(Let's Encrypt) SSL 인증서 발급 
* 해당 방법 적용시 도메인이 필요 <br>
`Cloud Domain 구입후 Cloud DNS로 사용함.`

* certbot 설치
```bash
yum install -y certbot
```
<br>

* certbot 버전 확인
```bash 
certbot --version
certbot 1.11.0
```
<br>

* Certbot 인증방식
1. standalone
   	- 80포트 사용하여 가상의 웹서버를 띄워 인증서를 발급합. 80포트 사용중인경우 중지후 사용해야함.. 
3. webroot 
   	-  webroot 경로를 직접지정하여 인증서 발급  $\textcolor{orange}{\textsf{* HAProxy에서는 오류 발생 }}$   

<br>

* standalone 방식 사용
```bash
certbot certonly --standalone -d testdomainname.info
```
<br>

* webroot 방식 사용
```bash
certbot certonly --text --webroot --webroot-path /etc/haproxy -d testdomainname.info
```
<br>


* pem 파일 생성
```bash
cd /etc/letsencrypt/live/testdomainname.info/
cat cert.pem chain.pem privkey.pem >site.pem
```
<br>


- 기존 설정파일 백업
```bash
cd /etc/haproxy/; cp haproxy.cfg haproxy.cfg.org
haproxy -f /etc/haproxy/haproxy.cfg -c
```
<br>

- haproxy.cfg 수정

>vi haproxy.cfg 
```bash
global
    #log파일 설정
    log 127.0.0.1 local0
    log 127.0.0.1 local1 notice
    tune.ssl.default-dh-param 2048
    # SSL-LAB 권고사항 (A등급 : SSL V3 사용 x, TLS 1.0 / TLS 1.1 사용 x)
    ssl-default-bind-options no-sslv3
    ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
.
.
.

frontend http-redirect
        bind *:80
        bind *:443 ssl crt /etc/letsencrypt/live/testdomainname.info/site.pem force-tlsv12
        reqadd X-Forwarded-Proto:\ https
        redirect scheme https code 301 if !{ ssl_fc }
        acl url_static hdr_end(host) -i testdomainname.info
        use_backend  web-server if url_static

frontend https
        bind *:8080
        #bind *:443 ssl crt /etc/haproxy/certs/rootCA.pem force-tlsv12
		# OR
	#bind *:443 ssl crt /etc/letsencrypt/live/testdomainname.info/site.pem force-tlsv12
        mode http
        reqadd X-Forwarded-Proto:\ https		
        redirect scheme https code 301 if !{ ssl_fc }
        
	#acl url_static       path_beg       -i /static /images /javascript /stylesheets
        #acl url_static       path_end       -i .jpg .gif .png .css .js
	acl url_static hdr_end(host) -i testdomainname.info			#acl로 domian으로 들어오면 backend로 전달함.
	use_backend web-server if url_static			
	
        default_backend web-server

backend web-server
        balance roundrobin
        option forwardfor
        option httplog
        server web 192.168.1.4:80 check
		
#port forwarding 
#listen test-web 0.0.0.0:8090
#		mode http
#		option httpclose
#		option forwardfor
#		server test-web1 192.168.2.100:8090 check 
# 포트포워딩은 같은 포트로만 적용
```
<br>			

- haproxy.cfg 파일 검증
```bash
haproxy -f /etc/haproxy/haproxy.cfg -c
```
<br>

- HAProxy 재시작
```bash
systemctl restart haproxy
```
<br>


## Certbot 인증서 갱신

- 인증서 만료일 확인 
```bash
certbot certificates
```
<br>

- 인증서 갱신방법
```bash
systemctl stop haproxy
certbot renew --dry-run # 갱신 전 테스트
certbot renew
```
$\textcolor{orange}{\textsf{* 갱신 오류가 많이나면 limit 걸려서 다음날 가능하므로 주의 할것. }}$   
 <br>


* 강제갱신
```bash
certbot renew --force-renew --cert-name testdomainname.info-0001
```
<br>


## 인증서 등급 확인
* ssl-lab에서 A등급으로 나오는지 확인
	* ( CNAME(www.xxxxxx)이 아닌 A 레코드로 입력하여 확인)

<br>

## Cerbot 인증서 자동갱신 스크립트
$\textcolor{orange}{\textsf{* 동일 위치에 상세하게 작성한게 있으니 그걸로 사용할것. }}$   

[2.Linux/Certbot(무료ssl인증서)/certbot_자동갱신용스크립트.sh](https://github.com/wocheon/2.Linux/blob/main/Certbot(%EB%AC%B4%EB%A3%8Cssl%EC%9D%B8%EC%A6%9D%EC%84%9C)/certbot_%EC%9E%90%EB%8F%99%EA%B0%B1%EC%8B%A0%EC%9A%A9%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8.sh)

>vi renew_cert.sh
```bash
#!/bin/bash
systemctl stop haproxy
certbot renew --dry-run
cd /etc/letsencrypt/live/testdomainname.info/
cat cert.pem chain.pem privkey.pem >site.pem
systemctl start haproxy
certbot certificates
```


## 추가 - DNS-01 챌린지 사용하여 인증서 갱싱
- GCP의 Cloud DNS, AWS의 Route 53등을 사용중인 경우 DNS에 TXT레코드를 추가하여 인증하는 방식으로 인증서 갱신 가능
- 443 포트를 사용하며 HAProxy의 연결과는 독립적인 작업이므로 영향 없음
- 인증 과정중 트래픽 흐름이나 세션연결에 변화 없음
- 현재 서비스가 사용중이라 인증서 갱신이 어려운 경우 사용가능

> 예시 - GCP Cloud DNS를 통해 인증서 갱신
```
# Service Account 키파일을 사용하여 Cloud DNS를 통해 인증서 갱신 수행
certbot certonly --dns-google --dns-google-credentials [Service_Account_keyfile] -d example.com -d www.example.com -d sub.example.com

#갱신후 HAProxy 설정 리로드 (재기동 없이 설정만 재로드)
systemctl reload haproxy
```

