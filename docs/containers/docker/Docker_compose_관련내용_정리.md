# Docker Compose

- Docker Compose 
  - 복수 개의 컨테이너를 실행시키는 도커 애플리케이션이 정의를 하기 위한 툴
  - yaml파일에 작성된 환경 내용을 읽어 해당 내용에서 원하는 대로 컨테이너, 컨테이너간 연결, 볼륨, 네트워크 등을 만들어 준다. 
  - `key: value` 형태로 모든 내용을 작성한다
  - 동일 환경을 다시 만들거나 이를 확장하거나 약간의 수정이 있을 경우 매우 편리하게 사용할 수 있다. 

$\textcolor{orange}{\textsf{* yaml 파일의 확장자는 yml 또는 yaml 모두 사용 가능.}}$ 



## 도커 컴포즈 설치 

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

## docker-compose yml 파일 작성하기
* mysql DB와 연결된 WordPress 컨테이너를 생성하기

```docker
version: '3.1'

services:

  wordpress:
    image: wordpress    #base 이미지
    restart: always     #docker 데몬이 재부팅되더라도 항상 자동실행
    ports:
      - 8080:80         #호스트의 8080포트를 서비스의 80포트와 연결
    environment:        #-e옵션과 동일
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
    volumes:
      - wordpress:/var/www/html #로컬에 wordpress라는 볼륨을 만들어 컨테이너의 /var/www/html에 붙임
    depends_on:
      - db                      #실행순서를 결정한다. (db가 먼저 실행되면 wordpress가 실행)
                                #(DB가 완전히 안정적으로 동작 뒤 실행하는 것은 아님, 그냥 실행순서만 결정)

  db:
    image: mysql:5.7        
    restart: always
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_ROOT_PASSWORD: test123
    volumes:
      - db:/var/lib/mysql    #db라는 볼륨을 만들어 붙임

volumes:
  wordpress:
  db:
  #둘사이의 연결은 링크가 필요없이 자동으로 연결된다.
```

### docker-compose Container 실행
```
docker-compose up -d
```
- wordpress 와 mysql 컨테이너가 설치됨을 알수있음

### docker network/volume 확인
```bash
# docker network/volume 조회
docker volume ls 
docker network ls


# docker network/volume 상세 조회
docker volume inspect 이름
docker network inspect 이름
```

## yml 파일작성 요령
- 줄 맞춤이 매우 중요하며 tab키 인식 불가능하므로 스페이스바를 이용해야한다.
- 일반적으로 2,4,6 혹은 3,6,9 단위로 띄워서 작성한다

1. `버전(version) 지정`
  -  docker compose의 버전 지정 

2. `서비스(services) 지정` 
  - 컨테이너의 스펙 
  - 컨테이너 구성, 같은 기능을 하는 서비스끼리는 라인맞추기 중요 
  - 옵션을 하나밖에 사용할수없는 경우에는 대쉬(-)를 사용하지않고 <br> 콜론다음에 한칸 띄워서 사용함 

3. `볼륨(volume) 지정`
  - 컨테이너가 사용할 볼륨 지정 (옵션)

4. `네트워크(networks) 지정`
  - 컨테이너 연결을위한 네트워크를 지정 (옵션)
  - 네트워크를 작성하지않으면 디폴트네트워크를 만들어줌
    - root가 지정하지않고 실행하면  root_default 
    - user1이 지정하지않고 실행하면 user1_default
  - 각 네트워크는 서로 독립적으로 존재한다.
  - 만약 오버레이네트워크를 구성하는경우 꼭 명시해 주어야한다.

5. `환경변수`
  - 환경변수 작성 방법은 두가지로 사용가능
  
  ```yaml
  WORDPRESS_DB_HOST: db  #1
  - WORDPRESS_DB_HOST=db #2 
  ```

## Docker-Compose 명령어

### compose로 실행한 컨테이너를 확인
```
docker-compose ps 
```
`(docker container ls 는 run + compose 모두 확인)`

### compose로 실행한 컨테이너를 정상 종료
```
docker-compose stop
```

### compose로 실행한 컨테이너를 강제 종료후 삭제 
```
docker-compose down 
```

### Docker-compose Conatiner Scale 변경
```bash
# 워드 프레스 3개 db2개 띄워라 
docker-compose up -d --scale wordpress=3 --scale db=2
# 실제 wordpress container는 1개만 동작함 
```

## YAML 파일 변경을 통한 서비스 포트 변경
- yml파일에서 
```bash
ports:
      - 8080:80
      # 해당 부분을 8080-8088:80 으로 수정 (범위를 지정함)
```      
- 결국 전부 8080으로만 접속되게 된다. <br>
`(볼륨에 처음 설치했던 설정이 남아있기때문임)`

- 결국 여러대의 워드프레스 서버를 위해서는 자체 호스트 서버를 늘려야만 한다.
  - 이를 자동으로 설정하는것이 `auto-scaling`이다.


-클라우드(AWS)의 완전관리형 서비스
  - 별도의 서버, 운영체제 과정없이 서비스 신청하면 즉시사용할수 있는 형태
  - OS서비스자원관리는  사용자관리가 아닌 공급자가처리 


## docker compose파일에서 dockerfile을 사용하는방법
>ex) 
```docker
services:
 webserver: 
    build: .
```
- docker build . 를 실행시킴     



