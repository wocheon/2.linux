
# Docker Swarm

## 클러스터링 
  - 클러스터를 구성하게되면 자원공유가 가능해진다.
  - 일종의 풀에 자원을 넣고 공유하는 방식이다.
  - 거리상 떨어져있어도 구성가능


## [실습]-docker swarm으로 클러스터링 구성하기 
```
docker-compose down
systemctl restart Docker
docker system prune

init0 
```

- 풀클론으로 4개를 생성하기

```
docker01 manager manager01 211.183.3.100
docker02 worker worker01  211.183.3.101
docker03 worker worker02  211.183.3.102
docker04 worker worker03  211.183.3.103
```
- 모든 노드에는 아래의 내용을 /etc/hosts에 등록한다.

```
211.183.3.100 manager01
211.183.3.101 worker01 
211.183.3.102 worker02 
211.183.3.103 worker03 
```
- 모든 노드는 multi-user.target(CLI)로 부팅되도록 설정하고
SSH로 연결하기

```
apt-get install ssh; systemctl enable sshd ; systemctl set-default multi-user.tartget ; reboot
```

* manager 노드
    - 클러스터 내부에서 작업을 주도하는 서버를 의미
    - 클러스터 내부에 1대이상 존재해야한다.
    - 기본적으로 worker의 기능을 겸업한다.

* worker 노드 
    - manager의 작업지시를 받아서 이를 수행하는 서버

- manager와 worker는 반드시 동일 네트워크상에 배치되어야하는 것은 아니며<br>
물리적으로 떨어져있는 상태에서도 클러스터링이 가능하다.

- manager를 하나만 사용하는 경우 만약 manager가 다운되면 작업지시가 불가능
    - 보통은 이중화를 통해 manager를 2대이상 배치한다.

## Docker swarm init
```
user1@manager01:~$ docker swarm init --advertise-addr 211.183.3.100
Swarm initialized: current node (t53349nsr5c6ayljryesrlmdb) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4uttvii6wqyz5zosctj4scixq71lsdl3eqrgtwldeohprmr70h-1znj9tezgcbih8f6e47nf0m9x 211.183.3.100:2377 

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
* `docker swarm join --token` 부분을 복사하여 worker 노드에서 join

## Docker Swarm 명령어

### 노드간 연결상태 확인
```
docker node ls
```
 
### 4개의 노드에서 각각 nginx 컨테이너로 접속하기
```
docker service create --name web --replicas 4 -p 80:80 nginx
```
### swarm으로 실행된 컨테이너 확인
```
docker service ps web 
```
### swarm으로 실행된 컨테이너 모두 내리기
```
docker service rm web
```

### 매니저를 제외한 2개의 노드에서 ngix컨테이너를 배포시키기
```
docker service create --name web --constraint 'node.role != manager'  --replicas 2 -p 80:80 nginx
```

* 2개를 배포하여도 다른 곳에서 접근이 가능하다.
- 클러스터를 구성하게되면 자동으로 오버레이 네트워크가 구성
    - 다른 노드에서도 접속이 가능


## 매니저에서는 배포하지않도록 설정했으므로 worker01에서 두개가 돌아감
docker service scale web=4

## 노드 하나를 중지시킴
```
docker node update --availability drain worker01
```

* docker service ps web로 확인해보면 3번에서 새로운 컨테이너를 만들어
동작시키고있는것을 확인 가능


### 매니저를 제외한 나머지 모든 노드에 공평하게 하나씩 컨테이너를 배포한다.
```
docker service create --name web --constraint 'node.role != manager' --mode global -p 80:80 nginx
```



## 토큰 발행 이후 manager 를 2개로 늘리고 싶다면??
### 1. 첫번째 방법
* 토큰발행하고 이를 이용하여 워커들이 스웜 클러스터에 조인한다. 
```bash
user1@manager01:~$ docker swarm init --advertise-addr 211.183.3.100  Swarm initialized: current node (msfctow4b3bn44r6cc6ezqe1f) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5irkus71dikt64psicehk7s9llthtaik67a7g463eloknjro8z-akz0saaujn5a25i1m4s3q1mrh 211.183.3.100:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

* 아래의 내용을 다른 노드에서 실행하면 매니저로 가입된다. 
```bash
user1@manager01:~$ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5irkus71dikt64psicehk7s9llthtaik67a7g463eloknjro8z-3vny7i8bdldi2d51161ntd3j9 211.183.3.100:2377

user1@manager01:~$
```

### 2. 두번째 방법 
- 매니저에서 아래 내용을 실행한다.
```bash
docker node promote worker01 
# worker01 을 worker 에서 manager 로 변경시킨다. 
```


## ingress네트워크
- 도커 클러스터가 구성되면 ingress네트워크가 새로 생성된다.
```bash
$ docker network ls 
NAME              DRIVER    SCOPE
ingress           overlay   swarm
```

## 롤링업데이트 
- 동작중인 컨테이너의 이미지를 새로운이미지로 업데이트 시키는 것
- 서비스의 중단없이 신규 서비스를 배포 가능.

### Rolling Update 예제
* Dockerfile 생성
>vim Dockerfile
```docker
FROM centos:7
RUN yum -y install httpd
ADD index.html /var/www/html
CMD /usr/sbin/httpd -D FOREGROUND
#index.html에 vr1표시
```
* docker 이미지 build
```bash
docker build -t myweb:1.0 .
```

* docker Swarm container 생성
```bash
docker service create --name web --mode global --constraint 'node.role == worker' -p 80:80 nginx
```

* index.html 내용 변경
    - index.html에 vr2표시

```bash
docker build -t myweb:2.0 .
docker service update --image myweb:2.0 myweb
docker service rollback myweb
```


- 라벨을 추가하여 특정 노드에만 서비스 배포
```bash
docker node update --label-add srv=nginx worker01
docker node update --label-add srv=nginx worker02
docker node update --label-add os=centos worker02
docker node update --label-add os=centos worker03

docker service create --name nginx -p 8001:80 --constraint 'node.labels.srv == nginx' --replicas 2 nginx
docker service create --name httpd -p 8003:80 --constraint 'node.labels.os == centos' --replicas 2 httpd
# nginx : nginx 기본페이지
# centos : itworks! 
```

```bash
docker service create --name nginx -p 8001:80 --constraint 'node.labels.srv == nginx' --replicas 2 nginx;
docker service create --name httpd -p 8003:80 --constraint 'node.labels.os == centos' --replicas 2 httpd
```



## docker swarm 볼륨옵션 사용하기
- 모든 노드에 존재하는 디렉토리만 연결할수 있음
```
docker service create --name nginx -p 80:80 --constraint 'node.role == worker' --replicas 2 --mount type=bind,source=/home/user1,target=/user/share/nginx/html nginx
```

- 각 서버별로 도커볼륨을 만들어 연결하기
```
docker service create --name nginx -p 8001:80 --replicas 2 --mount type=volume,source=test,target=/root nginx

docker service create --name nginx2 -p 8001:80 --replicas 4 --mount type=volume,source=test,target=/root nginx
```
- 이러한 방법을 사용하면 각 컨테이너의 볼륨내의 정보가 동일하지않음
- 그러므로 외부에 있는 스토리지를 사용하여 nfs등으로 연결해준뒤 사용하는것이 추천됨


## docker stack 
- docker swarm + docker-compose
- 서비스 제공환경을 yml파일에 작성하고 <br>이를 클러스터(swarm)환경에 일괄적으로 배포할수 있다.


## --attachable 옵션
- docker container run으로 만들어진 컨테이너들도 오버레이네트워크에 속할수있음
```
docker network create --driver=overlay --attachable web 
```
## external : true 
-  껏다가 켜도 네트워크 정보를 유지하겠다.


## Docker Swarm 실습
- centos 7 에 httpd 를 설치하고 웹페이지를 인터넷에서 받아서 사용하기

### 웹페이지용 css 파일 다운로드
```bash
wget https://www.free-css.com/assets/files/free-css-templates/download/page266/radiance.zip
# add로 붙이는과정에서 디렉토리가 들어가버리는경우가 있으므로, unzip 하여 사용하기 
```


### VMware NetworkManager설정 
- NAT 네트워크의 port forwarding 설정하기
```
10.5.1.x:8080 > 211.183.3.100:80 >haproxy :80 > workers
```

### Dockerfile 작성
> vi Dockerfile
```docker
FROM centos:7
RUN yum install -y httpd
ADD ./radiance /var/www/html/
CMD /usr/sbin/httpd -D FOREGROUND
EXPOSE 80
```

### Docker image 빌드
```bash
docker build -t ciw0707/test:02 . 
# 도커허브에 올리기위해 이름을 다음과 같이 작성
```


### docker hub에 이미지 업로드
```
docker login
docker push ciw0707/test:02
```

## 다른 노드들로 이동하여 이미지 다운로드
```
docker login 
docker pull ciw0707/test:02
```

## yml파일 작성하기
> vim web.yml
```docker
version: '3'

services:

  nginx:
    image: ciw0707/test:02
    deploy:
      replicas: 3
      placement:
        constraints: [node.role != manager]
      restart_policy:
        condition: on-failure
        max_attempts: 3
    environment:
      SERVICE_PORTS: 80
    networks:
      - web

  proxy:
    image: dockercloud/haproxy
    depends_on:
      - nginx
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 80:80
    networks:
      - web
    deploy:
      mode: global
      placement:
        constraints: [node.role == manager]

networks:
  web:
    external: true
```

### docker swarm container 배포
```
docker stack deploy --compose-file=web.yml web
```

- 10.5.1.5:8080 혹은 211.183.3.100으로 접속하여 동작확인


## ansible 활용
### Ansible 설치

- Ubuntu
```
apt-add-repository ppa:ansible/ansible
apt-get update 
apt-get install -y ansible
```
- CentOS
```
yum -y update
yum -y install epel-release
yum -y install ansible
```


### /etc/ansible/hosts 파일 변경
```
211.183.3.101
211.183.3.102
211.183.3.103 
```

## sshd 설정
- /etc/ssh/sshd_config에서 PremitRootLogin yes 으로 변경후
```
systemctl restart ssh
systemctl restart sshd
```

## Ansible command
```
ansible all -m ping -k
ansible all -m user -a "name=user9" -k
ansible all -m shell -a "cat /etc/passwd | grep user9" -k
ansible all -m user -a "name=user9 state=absent" -k
ansible all -m shell -a "cat /etc/passwd | grep user9" -k



ansible all -m apt -a "name=git state=present" -k
 curl https://www.kbstar.com -o index.html
```


## Docker Swarm visualizer
>visualizer yml파일
```docker
version: '3'

services:
  visual:
    image: dockersamples/visualizer
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      mode: global
      placement:
        constraints: [node.role == manager]
```

- visualizer 배포
```
docker stack deploy -c visual.yml visualizer
```


## Dialog 사용법
```bash
yum install -y dialog
dialog --msgbox "hello all" 10 20
dialog --title "plz answer me" --yesno "doyou like me?" 10 20
echo $?

dialog --title "test" --inputbox "ur name?" 10 20 2>name.txt
cat name.txt
```