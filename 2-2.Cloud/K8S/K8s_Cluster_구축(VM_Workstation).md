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

## Docker 설치
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


## 쿠버네티스(K8S) 설치
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

## Node 2 , Node3 생성
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


## 쿠버네티스 

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
```
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