# Docker container로 HAProxy 구성

## 구성 
   - 한개 서버내에 Docker 컨테이너로 Web서버 Web-1, Web-2를 생성
   - Docker Container로 HAProxy를 구성하여 외부 연결 가능하도록 설정

## Docker Network 생성

```bash
$ docker network create test-network
```

* 생성 확인
```bash
$ docker network ls

NETWORK ID          NAME                DRIVER              SCOPE
6aac590125fc        bridge              bridge              local
35c9430ae570        host                host                local
577e7e7de212        none                null                local
81bb22215620        test-network        bridge              local
```

## Web Server 세팅
### WEB-1

* 작업용 폴더 생성
```bash
mkdir -p /root/docker-image/web-1/html
cd /root/docker-image/web-1
```

* Dockerfile 작성
>vi Dockerfile

```docker
FROM centos:7
RUN yum -y install httpd
ADD ./html/index.html /var/www/html/index.html
EXPOSE 80
CMD /usr/sbin/httpd -D FOREGROUND
```

* Docker Image에 포함할 Index.html 작성

```bash
cd /root/docker-image/web-1/html
```

>cat index.html
```docker
Docker Conatiner Test
image : centos:7
name : web-1
domain : testdomainname.info
volume : /root/docker-image/web-1/html
```
* Docker Image 빌드
```bash
docker build -t web-1 .
```
* Docker Container 실행
```bash
cd html
docker run -d --name web-1 -p 8080:80 --network test-network -v "$PWD":/var/www/html web-1
```

### WEB-2
* 작업용 폴더 생성
```bash
cd /root/docker-image 
cp -r web-1 web-2 
```

* Index.html 파일 내용 변경
```
cd /root/docker-image/web-2/html
```

>cat index.html
```docker
Docker Conatiner Test
image : centos:7
name : web-2
domain : testdomainnames2.com
volume : /root/docker-image/web-2/html
```

* Docker Image 빌드
```bash
docker build -t web-2 .
```

* Docker Container 실행
```bash
docker run -d --name web-2 -p 8081:80 --network test-network  -v "$PWD":/var/www/html web-2
```
## Docker Container IP 확인
* WEB-1
```bash
$docker inspect web-1 | grep IPA

            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAMConfig": null,
                    "IPAddress": "172.18.0.2",
```                    

* WEB-2
```bash
$docker inspect web-2 | grep IPA
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAMConfig": null,
                    "IPAddress": "172.18.0.3",
```


## HAProxy 컨테이너 생성
* 작업용 폴더생성
```
mkdir -p /root/docker-image/haproxy/haproxy.conf.d
cd /root/docker-image/haproxy 
```

* Dockerfile 작성
>vi Dockerfile
```docker
FROM haproxy:lts
USER root
```

* HAProxy Docker Image 작성
```bash
docker build -t  my-haproxy .
```

* HAProxy 설정파일 작성
>vi /root/docker-image/haproxy/haproxy.conf.d/haproxy.cfg

```bash
frontend http-redirect
  bind *:80
  mode http
  option httplog
  acl web-url-2 hdr_end(host) -i testdomainname.info
  acl web-url-1 hdr_end(host) -i testdomainnames2.com

  use_backend web-1 if web-url-1
  use_backend web-2 if web-url-2
  default_backend web-1

backend web-1
   balance roundrobin
   option forwardfor
   option httplog
   option tcplog
   server websrv-1 172.18.0.2:80  check

backend web-2
   balance roundrobin
   option forwardfor
   option httplog
   server websrv-2 172.18.0.3:80 check
```

* HAProxy Container 실행
```bash
docker run -d --name vlb --net test-network -p 80:80 -p 443:443 --restart always -v /root/docker_image/haproxy/haproxy.conf.d:/usr/local/etc/haproxy/ my-haproxy:latest 
```

