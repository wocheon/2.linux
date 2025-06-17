# Docker 관련 내용 정리

##  Docker 
- 자신의 커널을 사용하는 것이 아니라 컨테이너 형식으로 애플리케이션을 동작 시킨다.

- 커널은 호스트의 커널을 사용하므로 하이퍼바이저를 이용한 추상화 단계가 없으므로<br> 성능 저하가 거의 발생하지않는다.

- 각 애플리케이션을 컨테이너로 구분하므로 격리도가 높다.

- 이를 이용하여 RDS와 비슷한 서비스를 만들 수도 있다.

- 컨테이너 서비스는 도커가 유일하지는않다.
- `cgroup`,`namespace` 라는 리눅스의 기능을 이용하여 구현한 것이다.
    - `cgroup` 
        - 자원사용제한
    - `namespace`
        - 격리

## Docker 와  hypervisor 비교

### hypervisor 를 이용한 가상머신 | 인스턴스
- 격리도가 매우 높다.
- 각각의 커널을 갖는다.
- 각각의 분리된 자원을 사용한다.
- 성능이 저하된다(많은 경우 30%정도의 성능저하 발생)

### docker 
- 격리도가 높다
- host os의 커널에 직접 접속하므로 성능저하가 거의 없다. `(app의 성능이 떨어지지않는다)`
- 분리된 자원사용이 가능하도록 정책을 세울수 있다. `(일종의 quota를 적용하여 사용할 수있는 리소스 제한)`
- 성능 저하가 거의 없다.

```
bare metal VS hypervisor VS Docker 
    1.0         0.7         0.97 (메모리는 1.01)
```

##  Docker Image
- 컨테이너를 만들기위해서는 이미지가 필요하다

- 이미지는 사설,공인(도커허브), 로컬저장소를 이용하여 저장된다.

- 이미지 찾기 
    - 만약 tag를 부착하지않으면 최신버전의 우분투를 보여준다.

```docker
docker search ubuntu:18.04
            [image명]:[tag]
```
    
- 이미지 다운로드시 로컬에 해당이미지가 있으면 추가 다운로드 하지않는다.


## 컨테이너의 구분
1. OS용 컨테이너 
    - base이미지로 활용하는 경우가 많음

2. application용 컨테이너 
    - nginx, mariadb,mysql,httpd


## Docker Container 생성
### create 
- 컨테이너 생성 후, 중지됨 
```
docker container create --name websrv1 -d -p 8001:80 nginx
docker container start websrv1
```
### run 
- 컨테이너 생성 후, 자동으로 실행됨

```bash
docker container run --name websrv1 -d -p 8001:80 nginx
docker container run --name websrv2 -d -p 8002:80 nginx
```
* firefox에서 localhost:8001, 8002로 접속하여 nginx확인 
* 동작중인 컨테이너는 삭제가 불가능하므로 종료뒤 삭제 혹은 강제 삭제해야함

### Docker run 옵션 목록
```
docker container run ubuntu /bin/echo "hello world"
docker container run --name test01 --hostname test001 -it centos:7 /bin/bash
```

* `--name`
    - 지정하지않으면 자동으로 생성
* `--hostname`
    - 지정하지않으면 자동으로 생성
* `-it` 
    - 해당 컨테이너로 연결한다. (가상터미널을 이용함)
* `-d` 
    - 백그라운드에서 동작한다 (주로 서비스를 제공하는 컨테이너들에게 지정하는 옵션)
* `-p` 
    - 호스트의 포트와 컨테이너의 포트를 매핑 <br>
    `ex) 8001:80  > 8001은 호스트의 포트, 정적 PAT구성`

* `-v` (volume) 
    - 호스트의 특정공간과 컨테이너의 특정디렉토리(디스크)를 마운트

    - 호스트 디스크의 일정 공간을 컨테이너의 특정 디스크와 연결한다.
    
    - 다른 컨테이너의 디렉토리를 마운트 할수있다.
    
    - 컨테이너에 적용된 내용은 영구 저장되지않으며, 컨테이너 삭제시 해당 데이터도 함께 삭제되므로
      <br> 중요한 데이터는 백업 혹은-v 옵션을 통해 <br> 호스트의 특정지점에 디스크를 연결하여 사용하는 방법을 적용.

* `-w`
    - 작업 디렉토리 지정    
    - 사용예시 => `-w`=/test
        - 생성된 컨테이너에 자동으로 /test라는 디렉토리가 생성되며<br> 연결하면 바로 해당 디렉토리로 이동된 상태로 접속

* `-e` 
    - 시스템 환경변수 설정 `(전역변수)`        
    - 설정해야할 변수가 많은 경우 파일에 변수를 선언하고 이를 옵션으로 불러오는 방법을 사용할 수 있다.
>ex)
```bash
# -e 옵션 지정
 -e WORK=/test
# -env-file 지정  
 --env-file=파일명
```
```bash
#컨테이너 내에서 
$ echo $WORK 
/test 
```


### Docker Container Run 명령 진행 순서
```
docker container run --name websrv1 -d -p 8001:80 nginx
```

1. 로컬저장소에서 ngnix이미지를 찾는다
2. 없다면 dockerhub에 접속하여 nginx 이미지를 다운로드 `(저장은 로컬 저장소에 저장됨)`
3. 도커 데몬은 로컬에 저장된 nginx 이미지를 이용하여 컨테이너를 생성
4. 생성시 컨테이너의 이름은 websrv1 이되고 동작중인 컨테이너는 백그라운드에서 동작. <br>
또한 컨테이너 자신의 80포트를 호스트의 80001번 포트와 매핑한다.


## 각종 Docker 명령어 

### 현재 동작중인 컨테이너 확인
```bash
docker ps --all
docker container ls

#-a 옵션 : 동작중인 컨테이너 뿐아니라 모든 컨테이너를 보여줌 
docker contianer ls -a 
```

### 컨테이너 실행 및 중지
```
docker container start websrv1
docker container stop websrv1
```

### 컨테이너 내에서 명령어 실행
- 컨테이너에서 ping동작 확인
```
docker container exec 7f28dccae87a ping -c 4 www.google.com
```
- 호스트네임 확인
```
docker container exec 7f28dccae87a cat /etc/hostname
```

### 컨테이너 이름을 변경
```
docker container rename 7f28dccae87a test
```

### 컨테이너의 실시간 상태를 확인하기 
```
docker container stat test
```

### Docker Container 커널 및 hostname
```bash
docker container run - --name centos01 --hostname centos centos:7 /bin/bash
$ uname -a
# ubuntu의 커널을 사용하는 것을 알수있음
$ echo $HOSTNAME 
centos
# hostname이 centos로 되어있는 것을 알수있음
```

### 컨테이너에서 빠져나가기
- `ctrl` + `p`,  `ctrl` + `q` 
- 백그라운드에서 동작하는상태로 컨테이너에서 빠져나온다

### Container에 대한 자세한 정보 확인
```bahs
docker container inspect centos01
```
- docker 이미지는 key:value 형태로 되어있음을 확인 가능.

### 컨테이너로 접속
```
docker container attach centos01
```

### docker image 확인 
```bash
docker image ls
docker image ls nginx
```

### Docker Hub에서 이미지 검색
```bash
docker search MariaDB
```

### 도커 이미지 태그 변경하기
```bash
docker image tag centos:7 web:1.0
docker image tag web:1.0 user1/ciw0707-centos7:0.1
```

## Docker Image 만들기

### Dockerfile 생성
> vi Dockerfile 
```docker
FROM centos:7
RUN yum -y install httpd php php-mysql
ADD index.html /var/www/html/index.html
EXPOSE 80
CMD /usr/sbin/httpd/ -D FOREGROUND
```

### Docker image build 
```
docker build -t web:0.1 .
```

### Docker image 확인 및 container 생성
```
docker image ls

docker container run -d -p 8081:80 web:0.1
docker container run -d -p 8082:80 web:0.1
```
### Docker image 삭제 
```
docker image rm web:0.1
```

### 이미지가 사용중이더라도 강제로 삭제
```
docker image rm web:0.1 -f
```
### 이미지 ID로 구분하기
```bash
$ docker image ls 
centos                  7         8652b9f0cb4c   5 months ago   204MB
web                     1.0       8652b9f0cb4c   5 months ago   204MB
user1/ciw0707-centos7   0.1       8652b9f0cb4c   5 months ago   204MB
```
* 세 이미지 모두 ID값이 동일하므로, 이름만 다를뿐 동일한 이미지임.

## Docker 로 mariaDB Container 실행
```bash
docker container run --name mariadb01 -d -e MYSQL_ROOT_PASSWORD=test123 -e MYSQL_DATABASE=sqldb mariadb/server:10.2

docker container ls | grep mariadb01

docker container inspect mariadb01 | grep IPA
```


## 도커네트워크
- bridge : 가상의 스위치를 만든다 해당스위치는 자동으로 NAT된다.
- host : 호스트의 IP주소를  컨테이너와 공유하여 사용한다.
- null : 네트워크 없음
- overlay : 클러스터로 연결된 모든 서버에 동일한 하나의 네트워크가 생성, 지역에 상관없이 모두 연결된다.


## Dockerfile로 이미지 만들기 
- Dockerfile을 이용하여 이미지를 생성 > 기본적으로 로컬저장소에 저장
- 사설,퍼블릭 저장소에 업로드하여 다른 사용자와 공유하여 사용이 가능

- 컨테이너의 자료는 영구적인 자료가 아니므로 이를 백업할수 있는 기술이 필요<br>
`volume을 사용하여 해결이가능`

### Dockerfile 예시
>vim Dockerfile
```docker
FROM centos:7
RUN yum -y update
RUN yum -y install httpd
EXPOSE 80
ONBUILD ADD website.tar /var/www/html
CMD /usr/sbin/httpd -D FOREGROUND
```
- Centos7 이미지로 컨테이너를 생성
- yum update , httpd 설치
- 80 포트오픈
- website.tar를 /var/www/html에 압축해제
- httpd 데몬 실행


## Dockerfile 작성 요령
1. `FROM`
    - 베이스 이미지를 지정하는 것으로 새로운 이미지의 기본베이스가 된다
    - 이미지가 현재 로컬에 없다면 도커 허브에서 다운로드한다.
>ex)
```docker
FROM centos:7
```

2. `RUN`
    - 이미지내에 필요한 패키지 등을 설치하기위한 명령의 실행이 가능하도록 해준다.
    - 도커 파일 내에서 여러번 사용할 수 있다.
>ex) 
```docker
RUN yum install -y httpd php php-mysql git 
```


3. `EXPOSE`  
    - 생성될 컨테이너에서 오픈할 포트를 지정한다
>ex)
```docker 
# 웹서버 사용시 
EXPOSE 80 or EXPOSE 443
```

4. `CMD` 
    - 컨테이너가 실행된 다음 컨테이너 내에서 실행할 명령어를 작성
    - 일반적으로 CMD는 가장아래에 작성한다.
    - Dockerfile에서 한번만 사용할수있다. (스크립트도 사용가능)
>ex) 
```docker
#컨테이너 실행시 웹서버를 실행하는 경우 
#httpd 또는 nginx를 실행한다.
CMD /usr/sbin/httpd/ -D FOREGROUND
```        

5. `ENTRYPOINT`
    - CMD와 동일하게 컨테이너 실행시 전달할 명령어를 작성한다.
    - 이 또한 파일내에서 1번만 사용할수있음    


---

$\textcolor{orange}{\textsf{* CMD 와 ENTRYPOINT의 차이점 }}$ 
- `ENTRYPOINT` : 컨테이너 실행시 무조건 실행
- `CMD` : 컨테이너 실행시 docker run에서 동일 옵션이 있을 경우 실행되지않음
- 만약 컨테이너 실행시  다양한 명령 실행이 필요한경우 스크립트를 사용 <br>
`(스크립트를 사용하려면 먼저 copy로 전달해주어야함)`

---


6. `COPY` 
    - 이미지에 호스트상의 파일이나 디렉토리를 복사하는 경우 사용
    - ADD(COPY) 와 비슷한기능을 수행       
>ex)
```docker
COPY index.html /var/www/html/index.html
```    

7. `ADD` 
  - COPY와 동일한 기능을 수행하며, 추가적으로 웹상의 파일을 불러올수있다.
  - 또한 패키지 파일이 있다면 이를 압축 해제하여 디렉토리에 부착한다.

>ex) 
* COPY로 tar파일 복사
```docker
COPY test.tar /var/www/html
```
```bash
#컨테이너 내부에서 확인
$ ls /var/www/html/
test.tar
```
`-> 압축해제 x`

* ADD로 tar파일 복사
```docker
ADD test.tar /var/www/html 
```

```bash
#컨테이너 내부에서 확인
 ls /var/www/html/
a.jpg TESTDIR
```
​`-> tar파일 자동으로 압축해제`

<br>


8. `env` 
    - 환경변수($HOSTNAME) 선언이 가능 
    - 작성 방법
        1. 여러줄로 작성하기
        ```docker
        ENV MYNAME "user1"
        ENV MYORDER "coffe"
        ```
        2. 한줄로 작성하기 
        ```docker
        ENV MYNAME="user1" MYORDER="coffe"
        ```


9. `VLOUME`
    - 이미지에 볼륨을 할당하고자 할때 사용
    ```docker
    VLOUME["/var/log"]
    VLOUME /var/log
    ```

10. `WORKDIR`
    - 도커파일내에서 작업위치를 지정해준다
    - 경로 이동시 사용하는 방법

```docker
# /var/www/html 에서 index.html을 만들고 /etc로 이동
WORKDIR /var/www/html
RUN touch index.html  
WORKDIR /etc/ 
```


## 컨테이너의 파일을 백업하는 방법 
1. 컨테이너의 특정 디렉토리를 호스트의 특정 디렉토리와 마운트한다.
2. 컨테이너간 디렉토리 공유, 마운트 ( 잘사용하지않음)
3. 도커 볼륨을 사용한다. > iSCSI

- dockerfile에서는 옵션으로 vol을 사용하여 볼륨 사용이 가능
`(도커 볼륨만 지원)`

- 호스트에 가상의 디렉토리를 만들고 이를 컨테이너의 특정디렉토리로 사용함


## Mysql DB와 연동된 WordPress Container 생성
```docker
#mysql
docker container run -d --name wordpressdb -e MYSQL_ROOT_PASSWORD=test123 -e MYSQL_DATABASE=wordpress -v /home/user1/0422/wordpress_db:/var/lib/mysql mysql:5.7

#wordpress
docker container run -d -e WORDPRESS_DB_PASSWORD=test123 --name wordpress -p 8001:80 --link wordpressdb:mysql wordpress
```


## 도커 볼륨 만들기 
* testvol 볼륨 생성
```bash
docker volume create --name testvol
docker volume ls
```

* testvol 볼륨을 Ubuntu Container에 마운트
```bash
# testvol 을 /root에 마운트하고 /bin/bash로 접속
 docker run -it --name ubuntu01 -v testvol:/root ubuntu /bin/bash 
  ```

* /root로 이동하여 파일 하나 만들고 빠져나와서 <br> 컨테이너 삭제후
볼륨을 확인해보면 남아있는걸 알수있음

* 두번째 컨테이너에 볼륨을 다시 붙혀서 사용하면 <br> 첫번째 컨테이너에서 만든 파일이 남아있는 것을 알수있음 

### docker volume inspect
* 도커 볼륨의 상세정보 확인, 마운트 포인트도 확인가능
```bash
$ docker volume inspect testvol | grep IPA
mariadb01 ip ad 172.17.0.5
```

* 해당 마운트 포인트에가면 볼륨내의 자료를 확인 가능
>ex) 
```bash
cat /var/lib/docker/volumes/testvol/_data/voltest.txt 
```

* 특정 디렉토리를 볼륨으로 사용
```bash
docker container run -d -p 8831:80 -v /root/nginx:/usr/share/nginx/html nginx

$ echo "<h1> test </h1>" > /root/nginx/index.html
$ curl localhost:8831
<h1> test </h1>
```

## Docker image Repository (이미지 보관장소)

- 로컬저장소 
    - 자신의 컴퓨터내에있는 저장소, 자신만 사용가능

- 퍼블릭(공인) 저장소 
    - 도커허브같이 공개된 장소에 보관하는것을 의미한다
    - 다른 모든 사람들이 검색, 다운로드하여 사용가능 

- 프라이빗(사설) 저장소
    - 제한된 인원만 접근 가능한 저장소
    - ex) 도커 내부에 유료서비스를 이용하여 특정 계정에 대해서만 접근 가능하도록 하는것
    - AWS,GCP의 사설 저장소를 이용하는 경우 해당 프로젝트내에 참여중인 사람만 다운로드 가능 
    - 도커 레지스트리를 이용하여 회사 내부에 있는 서버에 사설 저장소를 구축하면 회사 내 직원들만 접근이 가능

## Docker image Repository 관련 실습 
- 로컬 저장소에 있는 이미지를 사설 저장소에 push 하고, 로컬 저장소 이미지는 삭제하기
- 사설 저장소에서 이미지를 다운로드하여 이를 이용한 nginx 서비스를 배포

### 작업 순서
1. Dockerfile 로 nginx 서비스 가능한 이미지 생성하기
2. registry 다운로드하여 사설 저장소 구축
3. 기존에 만든 이미지를 사설저장소에 올릴 수 있는 이미지로 tag  를 변경한다.
4. 사설저장소용 이미지는 사설 저장소에 push 하고 로컬 저장소에 있던 이미지는 삭제한다.
5. 사설저장소로 부터 이미지를 다운로드하여 nginx 서비스를 배포한다.


 * 참고 
    - nginx 이미지로 컨테이너 생성시  기본 홈디렉토리 
        - /usr/share/nginx/html 
    - ubuntu 이미지를 다운로드하여 RUN 으로 nginx 설치시 기본 디렉토리
        -  /var/www/html  `(apt-get 설치)`

1. (로컬)사설 저장소 구축하기
```bash
docker image pull registry
docker container run  -d -p 5000:5000 --name mypregi registry
```

2. Dockerfile 작성하여 이미지를 생성하기
* Dockerfile 생성
>vim Dockerfile 
```docker
FROM nginx
COPY 0422/index.html /usr/share/nginx/html
```

* 이미지 빌드
```bash
docker build -t test:nginx .
```

3. 사설 저장소에 이미지 업로드
```bash
docker image tag test:nginx localhost:5000/test:nginx
docker image push localhost:5000/test:nginx
```

4. 로컬저장소에있는 이미지를 삭제후에 사설저장소에서 이미지 불러오기
```bash
docker image rm test:nginx
docker image rm localhost:5000/test:nginx
docker image pull localhost:5000/test:nginx 

docker run -d -p 8009:80 localhost:5000/test:nginx 
```

## Quiz - web:0.2 버전 만들기
- 처음 접속시 localhost:8083 으로 접속
- 다음과 같은 화면을 출력
```bash
이름 : _____   확인

# 확인 누르면 화면에서 

    ___님 반갑습니다 출력 
```    

* Dockerfile 생성
>vi Dockerfile 
```docker
FROM centos:7
RUN yum -y install httpd php php-mysql
ADD index.html /var/www/html/index.html
ADD a1.php /var/www/html/a1.php
EXPOSE 80
CMD /usr/sbin/httpd/ -D FOREGROUND
```

* Docker 컨테이너 실행
```docker
docker build -t web:0.2 .

docker image ls

docker container run -d -p 8083:80 web:0.2
```

## QUIZ. Dockerfile 로 이미지 생성 및 배포
- centos를 다운로드하여 httpd php php-mysql git wget을 설치하고 80번포트는 오픈하라. 
- 로컬에있는 index.html파일을 이미지의 /var/www/html에 붙여넣기하라
- 또한 생성된 컨테이너는 웹서비스를 시작할수 있어야한다.
