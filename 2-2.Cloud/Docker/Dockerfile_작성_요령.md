# Dockerfile 작성요령

## Dockerfile 내 명령어 
1. `FROM`
  - 베이스 이미지를 지정하는 것으로 새로운 이미지의 기본베이스가 된다
  - FROM 다음에 베이스 이미지를 지정하고 로컬에 없다면 도커 허브에서 다운로드한다.

​2. `RUN`
  - 이미지내에 필요한 패키지 등을 설치하기위한 명령의 실행이 가능하도록 해준다.
  - 도커 파일 내에서 여러번 사용할 수 있다.

>ex)
```docker
RUN yum install -y httpd php php-mysql git 
```
​

3. `EXPOSE` 
  - 생성될 컨테이너에서 오픈할 포트를 지정한다

>ex) 웹서버 사용시 
```docker
EXPOSE 80 or EXPOSE 443
```
​

4. `CMD` 
  - 이미지에서가 아니라 컨테이너가 실행된 다음 컨테이너 내에서 실행할 명령어를 작성
  - 일반적으로 CMD는 가장아래에 작성한다.
  - Dockerfile에서 한번만 사용할수있다.(스크립트도 사용가능)

>ex) <br>
컨테이너 실행시 웹서버를 실행하는 경우 <br>
  => httpd 또는 nginx를 실행

<br>​
5. `ENTRYPOINT`
  - CMD와 동일하게 컨테이너 실행시 전달할 명령어를 작성한다.

  - 이 또한 파일내에서 1번만 사용할수있음 
  ​- 만약 컨테이너 실행시 웹서버 하나만 띄우는 것이 아닌 <br>
  다양한 명령 실행이 필요하다면 스크립트를 사용 <br> 

  `스크립트를 사용하려면 먼저 copy로 전달해주어야함`
  
  <br>

---

$\textcolor{orange}{\textsf{* CMD 와 ENTRYPOINT의 차이점 }}$ 
  - `ENTRYPOINT` : 컨테이너 실행시 무조건 실행
  - `CMD` : 컨테이너 실행시 docker run에서 동일 옵션이 있을 경우 실행되지않음

<br>

`* ENTRYPOINT/CMD 사용 - dockerfile기준`

- 만약 ENTRYPOINT 를 사용하여 container 수행 명령을 정의한 경우,<br>
해당 container가 수행될 때 반드시 ENTRYPOINT 에서 지정한 명령을 수행되도록 지정 된다.

- 하지만, CMD를 사용하여 수행 명령을 경우에는,<br>
container를 실행할때 인자값을 주게 되면 <br>
 Dockerfile 에 지정된 CMD 값을 대신 하여 지정한 인자값으로 변경하여 실행되게 된다.

- container가 수행될 때 변경되지 않을 실행 명령은 CMD 보다는 ENTRYPOINT 로 정의하는게 좋다.

- 메인 명령어가 실행시 default option 인자 값은 CMD로 정의해 주는게 좋다.

- ENTRYPOINT 와 CMD는 리스트 포맷 ( ["args1", "args2",...] )으로 정의해 주는게 좋다.

---


6. `COPY` 
  - 이미지에 호스트상의 파일이나 디렉토리를 복사하는 경우 사용
  - ADD(COPY) 와 비슷한기능을 수행 

<br>

7. `ENV`
  - 환경변수($HOSTNAME) 선언이 가능 
  - ENV 작성 방법

    1. 여러줄로 작성하기
    ```
    ENV MYNAME "user1"
    ENV MYORDER "coffe"
    ```
    2. 한줄로 작성하기 
    ```
    ENV MYNAME="user1" MYORDER="coffe"
    ```
​

8. `ADD` 
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

8. `VLOUME`
  - 이미지에 볼륨을 할당하고자 할때 사용

>ex)
```docker
VLOUME["/var/log"]
VLOUME /var/log
```
​

## Dockerfile 예시
* Wordpress-Mysql 연결
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