
# K8S

## K8S의 사용

- 퍼블릭클라우드 환경에서의 구성 
  - GKE
  - EKS

- 온프레미스에서의 구성 
  - Kubeadm 

- master 
  - 전체 클러스터 관리 및 배포
- nodes (worker) 
  - master로부터 작업을 지시받고 해당업무를 수행하여 pod를 배포

## k8s(kubernetes) 아키텍쳐

`master node`
- api-server 
  - 컨트롤 플레인(k8s의 제어판)의 front-tend, 관리 개발자와 상호통신

- key-value store(etcd) 
  - 클러스터 환경에 대한 구성정보를 담은 DB 
  - 마스터노드, pod, container들의 상태정보를 확인할 수 있다.

- controller 
  - 클러스터의 실행, 하나의 컨트롤러는 스케줄러를 참조하여 정확한 수의 pod실행 
  - 만약  pod에 문제 발생시 다른 컨트롤러가 이를 감지하고 대응함

- scheduler 
  - 클러스터의 상태가 올바른가, <br> 새로운 container 요청이들어오면 이를 어디에 배치할것인가? 등의 결정 담당

`worker node`
- master 로부터 업무를 전달받아 이를 처리하고 결과를 master에게 보고

- networkproxy(kube-proxy) 
  - 네트워크 통신담당 (다양한 모듈이있으므로 선택해서 설치해야함)

- kubelet 
  - 컨트롤러에서 노드에 작업을 요청하면 kubelet이 이를 받아 처리

- runtime 
  - kubelet 으로부터 작업을 받아 실제 container를 만드는 작업을 하는 도구 
  - ex) docker

`추가요소` 

- DNS 
  - 각 pod에 대해 내부적으로 사용할수있는 도메인이름을 할당하고 IP와 매핑하여 처리

- 영구디스크(Persistent Storage)
  - 사용자가 기본스토리지 인프라에 관한 정보를 몰라도 리소스 요청이 가능하다.
  
  - 개발자는 서버에 필요한 추가디스크를 서버에 연결하기위해 <br>
  `nfs`,`iscsi`,`fc` 등의 기술을 몰라도 요청내용 중 간단한 내용만을 요청하면,<br>
  관리자가 미리 풀에 만들어둔 디스크와 매핑되어 <br>
  자동으로 해당볼륨을 사용할수 있도록 해주는 기술

## 쿠버네티스(k8s) 용어 정리 

- 쿠버네티스의 기본 container 관리도구 
  - `docker` 

- pod 
  - container 1개이상을 묶어 서비스를 제공(상위개념 : 레플리카셋)
  - 반드시 동일한 노드상에 동시에 전개된다는 특징을 가짐

- 레플리카셋 
  - replicaset 5 5-1 +1  
  - 고정된 pod의 개수를 지정한다 (상위개념 : deployment)

- deployment 
  - rs,pod의 최상위개념, 롤링업데이트(사용중에 버전 업데이트 가능)을 지원

- 서비스
  - 클러스터 내부의 pod간 통신과 pod의 외부로의 노출을 위한 설정을 제공

- namespace
   - 작업공간의 분리를 담당

- etcd  
  - 클러스터 전체 구성도를 관리 > 일반적으로 별도 구축없이 master내에 구축
  - master가 한대인경우 master가 다운되면 <br>
  클러스터 전체구성의 확인 및 명령을 내릴수없으므로 클러스터 동작이 불가능 
  
      - 이로 인해 master는 2대이상을 구성하는 것이 일반적
  - 또한 etcd도 전체 클러스터 정보가 포함되어있으므로 2대 이상을 구성해주는 것이 좋다


- replicaset
  - auto-scale 구현가능 
    -  노드의 cpu ram등을 확인하여 자동으로 확장 수축하는것이 아닌 <br>
    replicaset 개수를 3에서 5로 지정하면 자동으로 pod가 5로 늘어나는 것을 의미
    - "scaling구현 가능하다" 생각 하는 것이 더 적절함


- 서비스 
  - pod로의 접속혹은 외부에서의 접근을 위한 서비스
  - cluster-ip : 외부로 노출되지 않는다. 클러스터 내부에서만 통신할 때 사용하는 IP
 
  - node-port : 외부 노출 가능. 트래픽 분산은 되지 않는다. 
  - LB : 일반적으로 기업에서 가장 많이 사용하는 서비스이며 트래픽 분산이 가능하다
    - on-premise 에서는 별도의 애플리케이션을 사용하여 기능을 구현
    - 퍼블릭 클라우드에서는 GCP,AWS  의 LB 를 바로 연결하여 사용할 수 있다. 

- Label
  - pod 단위로 label 을 붙여 트래픽 분산 또는 지정된 pod로의 접속을 유도할 수 있다.

- configmap 
  - pod들이 공통적으로 사용하는 변수등을 지정할때 사용한다
  - etcd에 담아둔다 이는 master,manager가 etcd와 직접 통신하므로 <br>
   master는 각 pod들의 변수 값을 한번에 확인할수있다.
  - configmap의 값들은 모두 평문으로 저장
  

- secret 
  - 각 pod에서 사용하는 패스워드 api연결을 위한 키값등을 배포할때 사용
  - secret 은 암호화되어 저장되므로 확인 불가능 


# k8s 배포방법
- pod, 레플리카 셋, 디플로이 먼트 등을 배포...
  
  1. yml 파일 만들기
  
  2. 배포
    - kubectl apply(또는 create) -f test.yml 
  3. 삭제
    - kubectl delete -f test.yml 

- yaml파일작성시 참고 
```
kubectl api-resources
```

# K8s Cluster 구축<br> (VM Workstation - Ubuntu 18.04)

## Kubernetes Cluster 환경 구축

### 기본 구성
####  Node 구성
    - OS : Ubuntu 18.04
    - 방화벽 : disable (ufw disable)
    - IP 구성
        - master : 211.183.3.100
        - node1 : 211.183.3.101
        - node2 : 211.183.3.102
        - node3 : 211.183.3.103
    
    - Node 2,3은 처음부터 만들지 않고 패키지 설치후 
      Node1을  복사하여 생성

#### 전체 노드 공통 작업
```
apt-get install -y git curl wget vim
```

> vi /etc/hosts
```bash
211.183.3.100 master
211.183.3.101 node1
211.183.3.102 node2
211.183.3.103 node3
```
* Swap off
```bash
swapoff -a
```

- node1은 GUI 해제
```bash
systemctl set-default multi-user.target
```
- Master Node에 vmware tool 설치
    - VM 메뉴에서 -> install vmware tools... 클릭

```bash
cp /media/docker/VM[tab]/VM[tab] .
tar xfz VM[tab]
cd vmware-too[tab]
./vmware-install.pl
```
`=> 처음만 y 나머지는 모두 그냥 엔터`

- 각 노드별(master, node1) 로 IP,GW,DNS를 설정 후, node1 GUI 활성화
```bash
systemctl set-default graphical.target
```

#### Docker 설치
* Docker Repository 및 GPG KEY 등록
```bash
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-cache madison docker-ce 

apt-cache madison docker-ce-cli 
```


* Docker 설치
```bash
apt-get install docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic containerd.io

docker --version
```


#### 쿠버네티스(K8S) 설치
* k8s Repository 및 GPG KEY 등록
```bash
apt-get update

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -


cat <<EOF > /etc/apt/sources.list.d/kubernetes.list

deb http://apt.kubernetes.io/ kubernetes-xenial main

EOF

```

* k8s 설치
```bash
apt-get update

apt-get install -y kubelet kubeadm kubectl kubernetes-cni
```

#### Node 2 , Node3 생성
* node1 을 종료 후, 복사(Full Clone)해서 node2, node3 을 생성

* node2, 3 을 실행하여 아래의 내용을 점검
    1. hostname 변경하기
    
    2. IP 변경
        - node2 -> 211.183.3.102
        - node3 -> 211.183.3.103
    
    3. /etc/hosts 변경
        - 127.0.1.1 node1 > 127.0.1.1 node2
        - 127.0.1.1 node1 > 127.0.1.1 node3

    4. node1 ~ 3 까지는 모두 "systemctl set-default multi-user.target" 

* 모든 내용확인 후 reboot



* 각 노드에서 서로간에 ping 이되는지 여부 확인 <br>
`특히 각 노드에서 master 로는 반드시 ping 이 가능해야 한다.`


#### 쿠버네티스 클러스터 설정

### Kubeadm init
- master 에서 아래의 명령을 실행하면 토큰이 발행된다.

```bash
kubeadm init --apiserver-advertise-address 211.183.3.100 --pod-network-cidr=192.168.0.0/16

or

kubeadm init --apiserver-advertise-address 172.16.1.25 --pod-network-cidr=192.168.0.0/16
```

* Kubeconfig 세팅
    - kubeadm init 이 완료되면 해당 명령어를 실행하라고 출력됨
    - 복사하여 그대로 실행
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
```

* Token 값 확인
    - kubeadm init 이 완료되면 마지막에 토큰이 출력됨
    - Worker 노드는 토큰을 이용하여 master 에 join 하게 된다
```bash
kubeadm join 211.183.3.100:6443 --token 1by71b.fi41vzfwfhej3du6 \
--discovery-token-ca-cert-hash sha256:2beab8e2f7ebaa5364a22b8bc78d2f6ab5aecb358eef641076b9eeff618fdb3c
```


### Cluster Node 연결상태 확인
```
$ kubectl get node

NAME STATUS ROLES AGE VERSION
master NotReady control-plane,master 4m18s v1.21.1
node1 NotReady <none> 73s v1.21.1
node2 NotReady <none> 59s v1.21.1
node3 NotReady <none> 57s v1.21.1
```
`> 아직 CNI 플러그인이 없어서 Master-worker 간 연결불가능`


### 오버레이 네트워크를 위한 매니페스트 파일 설치
```
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
```


* Cluster Node 연결상태 재확인 
    - 연결확인에 약 2~3분 시간 필요

```bash
$ kubectl get node

NAME STATUS ROLES AGE VERSION
master Ready control-plane,master 11m v1.21.1
node1 Ready <none> 8m22s v1.21.1
node2 Ready <none> 8m8s v1.21.1
node3 Ready <none> 8m6s v1.21.1
```
`정상적으로 연결됨을 확인`


## K8S 토큰 
- 쿠버네티스 토큰은 만료기간이있음 
   - 일정시간동안 join하지않으면 또 다른 토큰을 발행해주어야한다.

- 토큰 조회
```bash
kubeadm token list
```

- token 뒤에는 ca-sha256으로 publickey를 hashing하여 붙여넣음
- node에서 master로 접속하려면 token 과 public키 두개가 필요하다
- /etc/kubernetes/pki/ca.crt 파일을 아래의 shell 을 이용하여 해시할 수 있다.

```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```



## K8S 서비스 종류

- 일반적으로 application의 배포는 yaml(or yml)파일을 구성하여 배포 
 
- `external-ip`
  - 외부에서는 접근불가능함
  - 노드간 통신에 사용됨

- `cluster ip` 
  - POD간의  연결을 위한 ip, kubernetes내부에서만  pod들에 접근가능
  - 외부로의 연결은 불가능 
  - 각 pod는 하나의 IP를 가지며 pod내의 container들은 하나의 IP를 공유하여 사용.

- pod(pod) 
  - 서비스제공의 최소단위, 1개이상의 container로 구성
  - 일반적으로 1개의 container로 구성하고 log,모니터링, 백업 등을 위해 <br>
  side-carcontainer를 사용할수있음 
  - 일반도커 container와 달리 발행 즉시 외부로의 연결이 되는 것이 아니다.

  - side-car 
    - 서비스를 제공하는데 영향을 주지않고, 없어도 상관은없으나 서비스에 도움을 줄수있는 container를 말함<br>
    - 일반적으로 실제 제공하는 서비스와 하나의 pod로 구성되어 배포됨 



## yaml파일을 통한 pod 배포하기 

### pod로 nginx 배포해보기

* yml파일 작성
>vi nginxpod.yaml 
```yml
apiVersion: v1
kind: Pod
metadata:
  name: my-first-nginx
spec:
  containers:
  - name: my-first-nginx-ctn
    image: nginx:1.10
    ports:
    - containerPort: 80
      protocol: TCP
```

* yml파일로 배포 진행
```
kubectl apply -f nginxpod.yaml
```

* 포드 확인
```
kubectl get pod
```

* pod에 대한 정보 확인 ( status,ip, 배포된 node위치)
```
kubectl get pod -o wide
```

* pod에 대한 더 자세한 정보보기 ( log, volume, ip, port 등등)
```
kubectl describe pod my-first-nginx
```

* pod 삭제 방법
  1. kubectl delete pod podname
  2. kubectl delete -f name.yaml


## sidecar 를 포함한 pod만들기 

>vi nginxpod.yaml 
```yml
apiVersion: v1
kind: Pod
metadata:
  name: my-first-nginx
spec:
  containers:
  - name: my-first-nginx-ctn
    image: nginx:1.10
    ports:
    - containerPort: 80
      protocol: TCP

  - name: test-ctn
    image: centos:7
    command: ["tail"]  #> 명령실행(ENTRYPOINT)
    args: ["-f", "/dev/null"] #> 명령실행(CMD)

```

- 해당 노드에서 docker container 확인
```
docker contanier ls 
```

- centos7 pod에 접속 
```
kubectl exec -it  my-first-nginx -c test-ctn bash
```

- pod는 도커의 container/stack과 달리 pod내부에있는 container들이
pod의 자원을 공유하여 사용한다.

- test-ctn 이 curl localhost를 통해 웹서버로 접속하면 <br>
  80번포트에서 서비스하고있는 my-first-nginx-ctn으로 웹접속이 됨

- 결국 한 pod에 속한 두 container는 80번포트를 각각 사용할수없음



## replicaset
- 고정된수의 pod를 지속적으로 동작시키는 것
- pod의 상위개념이며 pod의 설정값에 replica 부분이 추가되는것 


### replicaset 배포하기
>vi nginxrs.yaml 
```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-first-nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-first-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-first-nginx-ctn
        image: nginx:1.10
        ports:
        - containerPort: 80
          protocol: TCP

      - name: test-ctn
        image: centos:7
        command: ["tail"]
        args: ["-f", "/dev/null"]
```

-  rs( replica set ) 배포 및  확인
```bash
kubectl apply -f nginxrs.yaml 

kubectl get pod,rs -o wide
```


- pod를 하나 지우고 확인해보기
```bash
kubectl delete pod 

kubectl get pod,rs -o wide
#지워도 다시 새로운 pod가 생성된다
```


### replicas 변경
- replicas 를 4로변경해서 다시 배포해보기 
>vi nginxrs.yaml 
```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-first-nginx-rs
spec:
  replicas: 4 # 3 => 4 로 변경
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-first-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-first-nginx-ctn
        image: nginx:1.10
        ports:
        - containerPort: 80
          protocol: TCP

      - name: test-ctn
        image: centos:7
        command: ["tail"]
        args: ["-f", "/dev/null"]
```

```bash
kubectl apply -f nginxrs.yaml
kubectl get pod,rs
# pod 개수가 4개로 늘어남을 확인가능
```

## Deployment
- pod > replicaset > Deployment
- replicaset의 기능 + Rolling update
- 서비스의 중단없이 application을 업데이트할수있음
- 특정 시점을 스냅샷처럼 저장하여  롤백이 가능함
- 결국  서비스의 배포는 pod, replicaset의 구성은 필요x  <br>
`(Deployment만 구성해서 배포하면됨)`

### Deployment 배포
>vi nginxdeploy.yaml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-first-nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-first-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-first-nginx-ctn
        image: nginx:1.10
        ports:
        - containerPort: 80
          protocol: TCP

      - name: test-ctn
        image: centos:7
        command: ["tail"]
        args: ["-f", "/dev/null"]
```
> ReplicaSet과 차이점이 거의 없음 

* 배포 확인
```
kubectl apply -f nginxdeploy.yaml
kubectl get pod,rs,deploy
```

*  배포시점을 기록하기 
```
kubectl apply -f nginxdeploy.yaml --record
```

* 기록 확인하기 
```
kubectl rollout history deployment
```

## Application 업데이트(rolling update) 
1. yaml파일을 수정하여 업데이트 하는 방법 

2. kubectl set image deployment 를 이용하여 업데이트 

```bash
# 배포시점 기록하며 배포진행
kubectl apply -f dp.yml --record

#pod명 확인
$ kubectl get pod -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP             NODE         NOMINATED NODE   READINESS GATES
my-first-nginx-deploy-d44cfcbb7-6nmsj   1/1     Running   0          13s   10.244.1.100   k8s-worker   <none>           <none>
my-first-nginx-deploy-d44cfcbb7-mwnwl   1/1     Running   0          13s   10.244.1.99    k8s-worker   <none>           <none>
my-first-nginx-deploy-d44cfcbb7-w997w   1/1     Running   0          13s   10.244.1.98    k8s-worker   <none>           <none>

# 현재 pod의 image 버전 확인
$  kubectl describe pod/my-first-nginx-deploy-d44cfcbb7-8k8jv | grep Image:
    Image:          nginx:1.10


# 이미지 변경 및 기록
kubectl set image deployment/my-first-nginx-deploy my-first-nginx-ctn=nginx:1.16.1 --record

#pod명 확인
kubectl get pod -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
my-first-nginx-deploy-b9bd8794-qwnct    0/1     ContainerCreating   0          1s    <none>        k8s-worker   <none>           <none>
my-first-nginx-deploy-d44cfcbb7-6nmsj   1/1     Running   0          13s   10.244.1.100   k8s-worker   <none>           <none>
my-first-nginx-deploy-d44cfcbb7-mwnwl   1/1     Running   0          13s   10.244.1.99    k8s-worker   <none>           <none>
my-first-nginx-deploy-d44cfcbb7-w997w   1/1     Running   0          13s   10.244.1.98    k8s-worker   <none>           <none>
# > 기존 pod가 삭제되면서 재생성되는것을 확인 가능


# 변경된 pod의 image 버전 확인
$ kubectl describe pod  my-first-nginx-deploy-b9bd8794-qwnct | grep Image:
    Image:          nginx:1.16.1

# 변경 기록 확인
$ kubectl rollout history deployment
deployment.apps/my-first-nginx-deploy 
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=dp.yml --record=true
2         kubectl set image deployment/my-first-nginx-deploy my-first-nginx-ctn=nginx:1.16.1 --record=true


# 이전 기록으로 rollback 
$ kubectl rollout undo deployment my-first-nginx-deploy --to-revision=1
deployment.apps/my-first-nginx-deploy rolled back

#pod명 확인
$ kubectl get pod -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP             NODE         NOMINATED NODE   READINESS GATES
my-first-nginx-deploy-d44cfcbb7-22fnx   1/1     Running   0          15s   10.244.1.105   k8s-worker   <none>           <none>
my-first-nginx-deploy-d44cfcbb7-gx9n7   1/1     Running   0          14s   10.244.1.106   k8s-worker   <none>           <none>
my-first-nginx-deploy-d44cfcbb7-rptsd   1/1     Running   0          17s   10.244.1.104   k8s-worker   <none>           <none>

#이미지 rollback 확인
$ kubectl describe pod my-first-nginx-deploy-d44cfcbb7-22fnx | grep Image:
    Image:          nginx:1.10
```

## 롤링업데이트 실습 

### 자신만의 이미지 만들기 준비
```bash
curl www.centos.org>index.html
#vi 편집기로 The Centos Project 부분뒤에 version1붙여두기
```

### Dockerfile 작성
> vi Dockerfile
```docker
FROM nginx:1.10
EXPOSE 80
ADD index.html /usr/share/nginx/html/index.html
CMD nginx -g 'daemon off;'
```

### 이미지 생성
```
docker build -t testnginx:1.0 .
```
### 이미지 테스트용으로 run으로 배포해보기 
```
docker container run -d  --name test -p 8001:80  testnginx:1.0
```

### docker hub에 업로드를 위해 tag변경 
- 사전에 docker로그인 작업 필요 
- 혹은 secret을 생성하여 자동으로 docker hub에서 불러오도록 설정
```
docker tag testnginx:1.0 ciw0707/testnginx:1.0
```

### docker hub에 이미지 업로드
```
docker push ciw0707/testnginx:1.0
```

### 업데이트용 이미지 생성
- index파일의 version을 2.0으로 변경하여 testnginx:2.0 이미지를 만들기
- 같은 과정을통해 docker hub에 업로드


### deployment 배포용 yml파일 생성

>vi mydeploy.yaml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-test-nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-test-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-test-nginx-ctn
        image: ciw0707/testnginx:1.0
        ports:
        - containerPort: 80
          protocol: TCP
```
 
### Deployment 배포
- 작성된 yaml파일을통해 Deployment 배포
 ```
 kubectl apply -f mydeploy.yaml
 ```

- yml파일의 이미지명을 수정하여 업데이트 해보기



## K8S Sevice (svc)
- 서비스의 배포/접근을 위해서는 service를 사용해야한다.
- 서비스는 네트워크를 담당한다
- 각각의 기능을 object 라하고 object 내에서 service를사용해야만 <br>
외부노출,외부로부터의 접근이 가능해진다

### K8S Sevice 종류
- cluster-ip 
  - 클러스터간 통신주소
  - -p옵션이 없는 docker run과 동일( 외부와 통신불가)

- node-port 
  - 포드에 접근할수있는 포트를 클러스터의 모든노드에 동일하게 개방

- load balance(LB) 
  - 일반적으로 사전에 LB가 준비되어있는 환경에서 연결할수있는 방법.<br>
   `(yaml을통해 연결이 가능해야함)`
  - 보통은 AWS,GCP같은 퍼블릭환경에서 사용하기 용이함
  - 일반적인 환경이라면 node-port를 통해 충분히 서비스 가능함


### ClusterIP 예시

>vi servicecip.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  ports:
    - name: webport
      port: 8080
      targetPort: 80
  selector:
    color: black
  type: ClusterIP
  ```

- Cluster IP의 연결상태
```
nodeip :211.183.3.101 : 30394
                |
                |
Cluster IP : 10.109.76.218:8080
                |
                |
pod(s) IP : 192.168.x.x : 80 
```

###  NodePort 예시
  
>vi nodeport.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  ports:
    - name: webport
      port: 8080
      targetPort: 80
  selector:
    color: black
  type: NodePort
```

### 배포된 서비스 확인
```bash
$ kubectl get srv,deploy

service/my-svc       NodePort    10.109.76.218   <none>        8080:30394/TCP   28s
# 각 노드의 ip:30394와 cluster-ip:8080가 연결됨
# node port 는 랜덤으로 할당됨 (옵션주면 고정가능 - 30000번대부터..)
```

* master(211.183.3.100)으로 접속하여도 웹서버로 접속가능

### 고정된 노드포트를 사용하기 

>vi nodeport.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  ports:
    - name: webport
      port: 8080
      nodePort: 30001
      targetPort: 80
  selector:
    color: black
  type: NodePort
```

- service 상태 확인
Endpoint를 통해 현재 연결되어있는 pod들을 확인 가능
```bash
$ kubectl describe service/my-svc

Name:              my-svc
Namespace:         default
Labels:            <none>
Annotations:       kubernetes.io/change-cause: kubectl apply --filename=dp.yml --record=true
Selector:          color=black
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.107.151.228
IPs:               10.107.151.228
Port:              webport  9000/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.104:80,10.244.1.105:80,10.244.1.106:80
Session Affinity:  None
Events:            <none>
```
> 

## 실습 : HAProxy를 통해 서비스에 대한 외부접근 허용

- HAProxy 서버를 만들어서 외부에서 접속할수있도록 연결해보기 
- HAProxy 구성
  - OS : CentOS 7.0 (minimal install)
  - cpu 2, RAM : 2GB , HDD : 20GB
  - NIC : 
    ```bash
          ens32 : bridge   -> 10.5.101/102/103/104.           
          ____

          ens33 : VMnet8(NAT)   -> 211.183.3.99
    ```
 
- 웹 접속이 가능한 것을 확인 했다면 "롤업"을 하여 CentOS(Version 2) 가 보이도록 하세요



### 기존 서비스 제거
```
kubectl delete svc my-svc 
```

### 신규 서비스용 yml파일 작성
>vi serviceETP.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: my-svc-etp
spec:
  externalTrafficPolicy: Local       #<--- 추가
  ports:
    - name: webport
      port: 8080
      targetPort: 80
      nodePort: 30001
  selector:
    color: black
  type: NodePort
```

### External Traffic Policy: Cluster
  - yml파일에서 설정 가능한 옵션

  - 기본값은 Cluster
 
  - 노드에 생성된 포드가 존재하지 않더라도 클러스터 네트워크를 통해 타 노드로 연결을 유지하여 서비스를 제공해 주는 방식
    - 클러스터로 연결되어있는상태에서 외부접근이 들어오는경우, <br> 현재 node에 pod가 없다면 다른 node의 pod로 넘겨주게된다 

  - 현재 상태에서는 211.183.3.100 에 웹서비스를 위한 포드가 존재하지 않아도 해당 주소로 웹접속시 페이지가 보이게 된다. 

  - Cluster 의 경우 이러한 편리함을 제공하지만 타 노드를 경유하여 서비스가 제공되므로 <br> 트래픽 부하가 내부적으로 증가할 수 있으며 
  홉도 증가하게 되어 <br> 포드 입장에서는 접속자를 외부의 클라이언트가 아닌 타 노드의 IP로 오해할 수 있다.
  
  - 만약 Cluster 가 아닌 "Local" 로 변경되면 "노드IP:노드Port"  로 접속했을 경우 해당 노드에 생성된 포드로만 트래픽이 전달되고 타 노드로는 연결이 되지 않게 된다. 
    - Local로 변경하면, 현재 해당노드에 pod가없다면 접속이 불가능, 다른 클러스터에 속한 node로 넘겨주지않는다

  - 결과적으로 211.183.3.100(master) 으로 웹 접속 시 실제로는 포드가 없으므로 웹 서비스를 제공받을 수 없게된다.


### deployment my-test-nginx-deploy scale out
```
kubectl scale --replicas=2 deploy my-test-nginx-deploy
```

### 접속 확인 후 삭제
```
 kubectl delete -f ./
```
 >현재 위치에 존재하는 yaml 파일을 참조하여 서비스,pod들을 삭제





## 두개이상의 서비스를 한번에 배포시키기 

```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-test-nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-test-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-test-nginx-ctn
        image: ciw0707/testnginx:2.0
        ports:
        - containerPort: 80
          protocol: TCP

---
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  ports:
    - name: webport
      port: 8080
      targetPort: 80
      nodePort: 30001
  selector:
    color: black
  type: NodePort
```
 

## 네임스페이스 ( name space ) 

- 분리되어있는 별도의 작업공간, 포드, 레플리카셋, 디플로이먼트, 서비스 등과 쿠버네티스 리소스들이 묶여 있는 가상공간

-  --namespace 없을 경우 기본적으로 “default” 네임스페이스를 의미함

- kube-system 는 쿠버네티스 클러스터 구성에 필수적인 컴포넌트들과 설정값 등이 존재

- 노드(nodes)는 쿠버네티스의 오브젝트 이지만, 네임스페이스에는 속하지 않는 오브젝트

- 네임스페이스는 라벨보다 넓은 의미로 사용됨

- ResourceQuota 오브젝트 사용하여 특정 네임스페이스에서 생성된 포드의 자원 사용량 제한

- 애드미션 컨트롤러라는 기능을 이용하여 특정 네임스페이스에서 생성되는 포드에는 <br> 항상 사이드카 컨테이너를 붙이도록 할 수 있다

- 포드, 서비스 등의 리소스를 격리함으로써 편리하게 구분

- 네임스페이스는 컨테이너의 격리된 공간을 생성하기 위해 리눅스 커널 자체를 사용

- 일반적으로 네트워크, 마운트, 프로세스 네임스페이스등을 의미하며 <br>리눅스 네임스페이스와는 별개


* docker  : namespace- 작업공간 분리 , cgroup-리소스제한 


### namespace생성방법

1. yaml로 작성하기 

>vi ns1.yaml 
```yml
apiVersion: v1
kind: Namespace
metadata:
  name: develop
```
  - 생성 후 확인
```
kubectl apply -f ns1.yaml 

kubectl get ns 
```

2. 명령어로 생성하기 
```
kubectl get ns
kubectl get pod -n default

kubectl create namespace testns
``` 
> metadata 쪽에 namespace로 지정하여 사용가능 


### 특정 namespace에 리소스 배포하기 

>vi mydeploy.yaml 
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-test-nginx-deploy
  namespace: develop  # namespace 'devlop' 에 배포
spec:
  replicas: 1
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-test-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-test-nginx-ctn
        image: ciw0707/testnginx:2.0
        ports:
        - containerPort: 80
          protocol: TCP
```

* 배포 및 확인
```
kubectl apply -f mydeploy.yaml 

kubectl get pod,deploy
```
> 기본적으로 default namespace에서 동작중인 리소스를 확인하므로 목록에 뜨지않는다.

* 특정 namespace를 지정하여  리소스를 확인
kubectl get pod,deploy -n develop 


## config map/ secret ( 설정값을 포드에 전달하기 )
- yaml파일과 설정값을 분리할수 있다.

### configmap 
- 설정값중 일반적으로 변수 (환경변수), 파일의 내용등을 각 포드에 전달하고자 할때 사용
- 위와 같이 cofigmap 은 주로 변수 를 사전에 정의하고 이를 각 포드에 전달하여
- 포드에서 개발에 참여하는 모든 개발자들이 동일한 환경변수를 사용할 수 있도록 해 주는 것을 configmap 이라고 부른다. 

### configmap 작성하기 
```
- kubectl create configmap(cm) "configmap name" 설정값
```

### configmap 실습

```bash
#configmap 생성
kubectl create cm log-level-cmap --from-literal LOG_LEVEL=DEBUG

kubectl create cm start-k8s --from-literal k8s=kubernetes --from-literal container=docker


# 생성된 configmap 확인
kubectl get cm

 kubectl describe cm log-level-cmap
-------------------------------------------
Data
====
LOG_LEVEL:
----
DEBUG
--------------------------------------------

kubectl describe cm start-k8s
-----------------------------------------
Data
====
container:
----
docker
k8s:
----
kubernetes
-------------------------------------------

# configmap을 yml파일 형태로 확인
kubectl get cm log-level-cmap -o yaml
kubectl get cm start-k8s -o yaml
```


### configmap을 이용한 pod배포하기 

 >vi cmap1.yaml
```yml
apiVersion: v1
kind: Pod
metadata:
  name: container-env-test
spec:
  containers:
  - name: env-ctn
    image: centos:7
    args: ["tail", "-f", "/dev/null"]
    envFrom:
    - configMapRef:
        name: log-level-cmap
    - configMapRef:
        name: start-k8s
```

```bash
kubectl apply -f cmap1.yaml

$ kubectl exec container-env-test env | egrep -e '(k8s|LOG_LEVEL)'
LOG_LEVEL=DEBUG
k8s=kubernetes
```


#### 2개이상의 key:value 쌍이 있는데이터에서 <br>특정 key:value만을 적용시키는 경우

>vi cmap2.yaml
```yml
apiVersion: v1
kind: Pod
metadata:
  name: container-env-test
spec:
  containers:
  - name: env-ctn
    image: centos:7
    args: ["tail", "-f", "/dev/null"]
    env:
    - name: KEY1
      valueFrom:
        configMapKeyRef:
          name: log-level-cmap
          key: LOG_LEVEL
    - name: KEY2
      valueFrom:
        configMapKeyRef:
          name: start-k8s
          key: k8s
```

* 확인
```
 kubectl apply -f cmap2.yaml

 kubectl exec container-env-test env | grep KEY
---------------------------------------------
KEY1=DEBUG
KEY2=kubernetes
---------------------------------------------
```

### 특정 파일에 cmap적용하기 (camp을 파일에 마운트하기)

>vi cmap3.yaml
```yml
apiVersion: v1
kind: Pod
metadata:
  name: container-env-test
spec:
  containers:
  - name: env-ctn
    image: centos:7
    args: ["tail", "-f", "/dev/null"]
    volumeMounts:
    - name: cmap-volume
      mountPath: /etc/config

  volumes:
  - name: cmap-volume
    configMap:
      name: start-k8s
```


```bash
# 배포 진행
kubectl apply -f cmap3.yaml

# pod 접속 후 configmap 적용 확인
kubectl exec -it container-env-test -- ls -l /etc/config/
total 0
lrwxrwxrwx 1 root root 16 May 21 02:37 container -> ..data/container
lrwxrwxrwx 1 root root 10 May 21 02:37 k8s -> ..data/k8s


# volume 내용 확인
$ kubectl exec -it container-env-test -- cat /etc/config/k8s; echo ""
kubernetes

$ kubectl exec -it container-env-test -- cat /etc/config/container; echo ""
docker
```

### secret
- 설정값중 보안을 요하는 패스워드와 관련된 설정을 포드에 전달하고자 할때 주로 사용

- secret 설정
```bash
kubectl create secret generic my-password --from-literal password=test123
```

- file로 secret 설정하기
```bash
#패스워드 파일생성
echo -e "password1"> pw1

#패스워드 파일로 secret생성
kubectl create secret generic my-pass --from-file pw1 

# secrets 확인 
kubectl get secrets my-pass -o yaml
  password: cGFzc3dvcmQxCg==
# secert은 base64로 암호화 됨

# base64로 복호화
echo cGFzc3dvcmQxCg== | base64 -d ; echo ""
password1
```

- secret 생성 테스트 (dry-run)
```bash
kubectl create secret generic my-pwd --from-literal password=test123 --dry-run -o yaml
apiVersion: v1
data:
  password: dGVzdDEyMw==
kind: Secret
metadata:
  creationTimestamp: null
  name: my-pwd
```

- secret을 포함한 pod 배포
kubectl create secret generic my-password --from-literal password=test123

>vi secret1.yaml
```yml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-test
spec:
  containers:
  - name: secret-ctn
    image: centos:7
    args: ["tail", "-f", "/dev/null"]
    envFrom:
    - secretRef:
        name: my-password
```

```
kubectl apply -f secret1.yaml

kubectl exec secret-env-test env
```

- 시크릿을 사용할때 yaml 파일에 base64로 인코딩한값을 입력했더라도 <br>
시크릿을 포드의 환경변수나 볼륨으로가져오면 <br>
base64로 디코딩된 원래의값을 사용하게된다


### Secret을 통해 외부 repository에서 이미지 가져오도록 설정

참조 : https://kubernetes.io/ko/docs/tasks/configure-pod-container/pull-image-private-registry/

- secret 생성
```bash
kubectl create secret docker-registry registry-key --docker-username=ciw0707 --docker-password=********
```

- secret 정보 확인
```bash
$ kubectl get secrets registry-key -o yaml
apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOnsidXNlcm5hbWUiOiJjaXcwNzA3IiwicGFzc3dvcmQiOiJkaWFrMTM1MSEiLCJhdXRoIjoiWTJsM01EY3dOenBrYVdGck1UTTFNU0U9In19fQ==
kind: Secret
metadata:
  creationTimestamp: "2021-05-21T04:40:36Z"
  name: registry-key
  namespace: default
  resourceVersion: "80083"
  uid: 98a57af1-ac36-4db4-87cf-e9f3be2ddf6d
type: kubernetes.io/dockerconfigjson
```

- config.json 확인
>cat ~/.docker/config.json
```
{
        "auths": {
                "https://index.docker.io/v1/": {
                        "auth": "Y2l3MDcwNzpkaWFrMTM1MSE="
                }
        },
        "HttpHeaders": {
                "User-Agent": "Docker-Client/18.09.9 (linux)"
        }
```

- ID, 비밀번호 확인가능
```
echo "Y2l3MDcwNzpkaWFrMTM1MSE=" | base64 -d 
 ```



## PV(Persistent Volume) , PVC(Persistent Volume Claim) 

### PV(Persistent Volume) 
- 이미지를 이용하여  컨테이너(pod)를 배포 시 <br>
 컨테이너 내부에 저장된 데이터, 데이터베이스는 컨테이너가 삭제될경우 <br>
 동일하게 삭제되어 별도로 접근이 불가능
- 이를방지하기 위하여 사용하는 것을 Persistent Volume(영구볼륨) 이라고 한다

- 쿠버네티스는 특정노드에서만 데이터를 보관해 저장한다면
 포드가 다른 노드로 옮겨지거나 생성되면 해당데이터를 사용할수 없음 

- 그러므로 특정 노드에서만 포드를 실행해야하는 상황이 발생 이를 해결하기위한 방법이 바로 PV

- 네트워크로 연결해 사용할 수 있는 PV  의 대표적인 예는 NFS, EBS, Ceph,GlusterFS 등이 있다.

- 쿠버네티스는 PV 를 사용하기 위한 자체 기능을 제공하고 있다. 


### Persistent Volume 사용법

1. 호스트와의 마운트(NFS)를 사용한다 
    - 호스트의 특정디렉토리와 컨테이너의 특정디렉토리를 연결하기 

2. 컨테이너간 연결
    - 거의 사용하지 않는 방법

3. 별도의 도커볼륨을 컨테이너의 특정 디렉토리와 연결하는 방법(iSCSI) 
    - iSCSI : IP를 이용하여 연결되는 SCSI 


### NFS를 이용한 PV 마운트

- 연결방법
  1. 로컬호스트와 연결하기
  2. 원격지의 nfs-server 이용하기 

```
 NFS 서버 준비 -> 방화벽 해제 -> /etc/exports 에 아래 내용 추가
   /k8s     211.183.3.0/24(rw,sync,no_root_squash) 
*사전에 /k8s 디렉토리를 만들어 두어야 한다.

 -> nfs-server 실행(또는 재실행)
```


>vi deployvol.yaml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-first-nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-first-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-first-nginx-ctn
        image: nginx:1.10
        ports:
        - containerPort: 80
          protocol: TCP
        volumeMounts:
        - name: nodepath
          mountPath: /etc/localvol
        - name: nfspath
          mountPath: /etc/nfsvol

      volumes:
      - name: nodepath
        hostPath:
          path: /tmp
      - name: nfspath
        nfs:
          path: /k8s
          server: 211.183.3.99
```


```
kubectl apply  -f deployvol.yaml 
```

- nfs server 에서파일생성 후 확인

```
touch /k8s/PVtest
kubectl exec -it my-first-nginx-deploy-7dcc967476-tkkn6 -- sh
```

ls /etc/*vol
```
/etc/localvol:
total 52
drwxrwxrwt 2 root root 4096 May 18 06:57 VMwareDnD
drwx------ 2 root root 4096 May 21 00:28 ansible_command_payload_1nt3gkj0
drwx------ 2 root root 4096 May 21 05:32 ansible_command_payload_4f308bmf
drwx------ 2 root root 4096 May 21 05:40 ansible_command_payload_5fz1omi9
drwx------ 3 root root 4096 May 20 04:48 snap.gnome-calculator
drwx------ 3 root root 4096 May 20 04:48 snap.gnome-characters
drwx------ 3 root root 4096 May 20 04:48 snap.gnome-logs
drwx------ 3 root root 4096 May 20 04:48 snap.gnome-system-monitor
drwx------ 3 root root 4096 May 18 06:57 systemd-private-ec4887ffd7ea475291cf0a4434149590-ModemManager.service-vMYW7E
drwx------ 3 root root 4096 May 20 00:53 systemd-private-ec4887ffd7ea475291cf0a4434149590-spice-vdagentd.service-NBDpKq
drwx------ 3 root root 4096 May 18 06:57 systemd-private-ec4887ffd7ea475291cf0a4434149590-systemd-resolved.service-wUytl6
drwx------ 3 root root 4096 May 18 06:57 systemd-private-ec4887ffd7ea475291cf0a4434149590-systemd-timesyncd.service-fviBpz
drwx------ 2 root root 4096 May 18 06:57 vmware-root_614-2722697888

/etc/nfsvol:
total 0
-rw-r--r-- 1 root root 0 May 21 06:13 PVtest
```

### pvc를 이용한 pv할당 

> vi nfs-pv.yaml
```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
 capacity:
   storage: 1Gi
 accessModes:
   - ReadWriteOnce
 persistentVolumeReclaimPolicy: Retain
 nfs:
   path: /pvpvc
   server: 211.183.3.99
   readOnly: false
```
kubectl get pv



vi nfs-pod-pvc.yaml 
```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-nfs-pvc
spec:
 storageClassName: ""
 accessModes:
   - ReadWriteOnce
 resources:
   requests:
     storage: 1Gi

---
apiVersion: v1
kind: Pod
metadata:
 name: nfs-mount-ctn
spec:
  containers:
  - name: nfs-mount-ctn
    image: centos:7
    args: ["tail", "-f", "/dev/null"]
    volumeMounts:
    - name: nfs-volume
      mountPath: /mnt

  volumes:
  - name: nfs-volume
    persistentVolumeClaim:
      claimName: my-nfs-pvc
```
```
kubectl apply -f nfs-pod-pvc.yaml

kubectl exec -it nfs-mount-ctn -- /bin/bash
df -h | grep /mnt
```

- NFS연결시  1Gi로 마운트 시킨다 하더라도 NFS로 연결된 디렉토리의 실제 크기가 나타나게 된다.

- 그러므로 실제 1Gi로의 할당을 위해서는 애초에 파티션을 나누어 1Gi 디스크를 마운트하여 nfs로 공유하거나 혹은  iSCSI 를 사용해야 한다.

## pod의 자원사용량 제한
### 컨테이너의 자원사용량 제한
- cpus 직관적으로 CPU의 개수를 직접지정 
>ex)
```
 docker container run -d --cpus 0.5 nginx 
 #cpu의 50%를 할당하여 사용 
```

## K8S - LB

* 쿠버네티스 자체에서는 Load Blalancer를 제공하지않음
- metallb 오픈스택의 LBAAS 등의 오픈 소스프로젝트를 사용하거나 <br>
수동으로 HAProxy서버를 구축하여 사용할수 있음


### AutoScaling 실습 

- edustack-web.yml

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: edustack
spec:
  selector:
    matchLabels:
      color: black
  replicas: 1
  template:
    metadata:
      labels:
        color: black
    spec:
      containers:
      - name: edustack-web
        image: beomtaek78/edustack:1.0
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m

---

apiVersion: v1
kind: Service
metadata:
  name: edustack-np
spec:
  ports:
    - name: edustack-node-port
      port: 8080
      targetPort: 80
      nodePort: 30001
  selector:
    color: black
  type: NodePort
```


- 오토 스케일링을 위한 메트릭-서버 설치
```
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

- components.yaml 수정
```bash
#136번 줄에 추가
- --kubelet-insecure-tls  
```

- components 배포
```bash
$ kubectl apply -f components.yaml
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
```

- Node 별 cpu , 메모리 사용량 확인 가능
```bash
$ kubectl top no --use-protocol-buffers
#1000m : cpu 1개 ?

NAME     CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
node1    190m         4%     972Mi           52%
node2    192m         4%     983Mi           52%
node3    153m         3%     981Mi           52%
ubuntu   564m         14%    2390Mi          62%
```


- 오토스케일러 작성하기 
>vi hpa.yml
```yml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: test-hpa
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: edustack
  targetCPUUtilizationPercentage: 20
```
```
kubectl apply -f hpa.yml
```

- 커맨드로 생성
```
kubectl autoscale deploy edustack --cpu-percent=20 --min=1 --max=15
kubectl get hpa
```

- 인위적으로 부하를 주어 autoscaling 작동확인
  - centos 서버를 하나 동작시켜서 yum -y install httpd-tools 설치
```
 ab -c 100 -n 300 -t 60 http://192.168.2.100:30001/

kubectl top no --use-protocol-buffers,  kubectl get hpa,pod
```


## 실습용 시나리오

- 현재까지 작성된 모든 오브젝트 중 pod, rs, deploy, service, hpa 등등을 모두 삭제하라.

- kubernetes 클러스터 환경에서 아래의 조건을 만족하는 환경을 구축하라
 
- 이미지는 centos 내에 httpd  를 설치하고 80번 포트를 오픈한다. 단, 페이지의 내용은 임의대로한다.
 이미지는 1.0 버전과 2.0 버전 두개를 작성하고 index.html 파일의 내용만 달리한다. 두 이미지는 docker-hub에 미리 upload 해 둔다.
- deploy 를 이용하여 1.0 이미지의 pod 를 배포한다. 단, 초기는 1개만 배포한다.
- 이미지를 다운로드 할 때에는 Secret 을 적용하여 dockerhub 의 계정을 통해 이미지를 다운 받을 수 있어야 한다.
  - (각 노드에서 docker login 하지 말것)
- Service 를 이용하여 외부에서 해당 포드로 접속이 가능해야 한다. 단, type 은 nodePort 를 사용하고
 이를 외부에 구성된 HAProxy 를 통해 접근할 수 있어야 한다.
- auto-scale 을 구성하여 외부 접속량에 따라 자동으로 스케일이 up->down 될 수 있어야 한다.

- 외부에서 트래픽을 전송하고 이를 처리하는 결과를 그래프로 나타내라
   이를 위해 외부에서 트래픽은 ab 를 이용하고 그래프는 gnuplot 을 이용한다.
   그래프는 시간에 따라 외부에서 전송된 트래픽을 처리한 결과가 나타나야 한다.    

- 그래프의 결과를 토대로 deploy 내의 컨테이너에 대한 resource 를 적절히 조정하고 다시 외부에서 ab 를 이용하여 
처리하는 시간을 줄이는 조정을 적용하라.

- 추가) 프로메테우스+그라파나를 적용하여 그래프로 리소스에 대한 처리 내역등을 시각화 하라
    - 참고 : https://arisu1000.tistory.com/27857?category=787056

- 위의 과제가 완성된 사람은 결과를 jpg 파일로 작성한 뒤 이를 upload 하세요!!



