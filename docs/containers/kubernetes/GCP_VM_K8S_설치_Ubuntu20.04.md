# GCP VM 쿠버네티스(K8S) 설치
* GKE가 아닌 VM에 직접 K8S를 설치

## K8s Cluster 구성
<table style="border:1px">
  <tr>
    <td style="text-align: center; vertical-align: middle;">옵션</td>
    <td style="text-align: center; vertical-align: middle;">Master</td>
    <td>Woker1</td>
    <td>Woker2</td>    
  </tr>
  <tr>
    <td style="text-align: center; vertical-align: middle;">리전</td>
    <td colspan="3" style="text-align: center; vertical-align: middle;">asia-northeast3-a</td>
  </tr>
   <tr>
    <td style="text-align: center; vertical-align: middle;">OS</td>
    <td colspan="3" style="text-align: center; vertical-align: middle;">Ubuntu 20.04 LTS</td>
  </tr>
  <tr>
    <td style="text-align: center; vertical-align: middle;">SPEC</td>
    <td>E2-medium</td>
    <td style="text-align: center; vertical-align: middle;" colspan="2">E2-small</td>
  </tr>
  <tr>
    <td style="text-align: center; vertical-align: middle;">Disk Size</td>
    <td style="text-align: center; vertical-align: middle;" colspan="3">10GB</td>
  </tr>  
</table>

`* 기본세팅 ~ K8S 설치까지 모든 노드에서 공통으로 진행`

## 기본 세팅
### 패키지 업데이트
```bash
apt update -y && apt upgrade -y
```

### SWAP 메모리 해제
* 각 노드에서 kubelet 컴포넌트가 제대로 동작하기 위해 리눅스의 SWAP 메모리 기능을 해제.
```bash
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab ; swapoff -a ; cat /etc/fstab
```

## DOCKER 설치
### 도커 설치에 필요한 패키지 다운로드
```bash
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release
```
	

### 도커 공식 GPG key 등록	
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### 도커 Repository 설정
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```  
  
### 도커 설치
```bash
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io  
``` 
 
### 도커 cgroup driver 설정
- 도커가 설치 후, 도커가 사용하는 드라이버를 쿠버네티스가 권장하는 systemd로 설정.
- 참고 : https://kubernetes.io/ko/docs/setup/production-environment/container-runtimes/

```bash
sudo mkdir /etc/docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
``` 

### 도커 재시작 및 부팅시 시작 설정
```
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## K8S 설치

### Container.d 런타임에 대해서 CRI 비활성화 해제 ('23.01 추가)

`* k8s 버전업그레이에 따른 추가사항`
- Docker 설치 후, container.d를 런타임으로 사용하는데, 기본적으로 CRI가 비활성화 되어있음.
- k8s에서 CRI를 사용할 수 있도록 변경. `(Master, Worker Node 모두)`

 >vi /etc/containerd/config.toml
```bash
 disabled_plugins = ["cri"]  #해당 구문을 주석처리 후 저장
```

* Containerd 재시작
```bash
systemctl restart containerd
```
 
 
### 방화벽 및 네트워크 환경설정
* 쿠버네티스 환경에서 서로 노드간의 CNI를 통해서 통신을 하기 위한 설정
```bash
modprobe overlay
modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```

### kubeadm, kubelet, kubectl 설치
- kubeadm
  - 클러스터를 부트스트랩하는 명령
- kubelet
  - 클러스터의 모든 머신에서 실행되는 파드와 컨테이너 시작과 같은 작업을 수행하는 컴포넌트
- kubectl
  - 클러스터와 통신하기 위한 커맨드 라인 유틸리티


#### 1.패키지 업데이트 및 설치 시 필요한 패키지 다운로드
```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

#### 2. 구글 클라우드의 공개 사이닝 키 다운로드
```bash
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```

#### 3. 쿠버네티스 Reposiotry 추가
```
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 
```

#### 4. kubelet, kubeadm, kubectl 설치
```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl
```


## K8S 클러스터 구성

`Master node에서만 수행`

* /etc/hosts 수정
>vi /etc/hosts
```bash
10.178.0.14	master
10.178.0.15	worker1
```

### CNI 별 kubeadm init 

* Flannel
```
kubeadm init --pod-network-cidr=10.244.0.0/16
```
* Flannel 사용 시 pod-network-cidr를 10.244.0.0/16 대역 사용

* calico
```
kubeadm init --apiserver-advertise-address 10.178.0.14 --pod-network-cidr=192.168.0.0/16
```
* calico 사용 시 pod-network-cidr를 192.168.0.0/16 대역 사용 <br>
`GCP VM 대역을 192.168.0.0/16 사용중이므로 flannel과 동일한 대역으로 변경`


### kubeadm init 결과

```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube;
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
sudo chown $(id -u):$(id -g) $HOME/.kube/config;

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.178.0.14:6443 --token 8lszl8.29tcsnpsxl1n8ex5 \
        --discovery-token-ca-cert-hash sha256:b5ea4609103a0f476b0e55e30c341b7fb913dfd1679fab1e8e4d67bec193a56c
```
* 아래 kubeadm join 구문을 사용하여 worker node에서 클러스터 Join


## Pod network add-on (CNI) 설치하기

* 구성한 클러스터 내에 CNI (Container Network Interface)를 설치
  - Pod들이 서로 통신이 가능하도록 설정


* CNI 별 특징 정리

|Provider|Network<br>Model|Route<br>Distribution|Network<br>Policy|Mesh|External<br>Database|Encryption|Ingress/Egress<br>Policies|Commercial<br>Support|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:
|Calico|Layer 3|Yes|Yes|Yes|Etcd|Yes|Yes|Yes|
|Canal|Layer 2<br>vxlan|N/A|Yes|No|Etcd|No|Yes|No|
|Flannel|vxlan|No|No|No|None|No|No|No|
|kopeio-networking|Layer 2|N/A|No|No|None|Yes|No|No|
|kube-router|Layer 3|BGP|Yes|No|No|No|No|No|
|romana|Layer 3|OSPF|Yes|No|Etcd|No|Yes|Yes|
|Weave Net|Layer 2<br>vxlan|N/A|Yes|Yes|No|Yes|Yes|Yes|

* 여러개의 CNI Plugin이 존재하나 이번에는 `Flannel`, `Calico`를 사용
<br>
### CNI Plugin - Calico 사용 시
* Master Node에서 작업 진행

* 참조 : [Calico 공식홈페이지 - Calico 설치 방법](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises)
### master Node에서 실행
*  operator 설치
```
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
```
* custom-resources 설치
```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
```

* Containerd, Kubelet 재시작
```bash
systemctl restart containerd
systemctl restart kubelet
```


* Node 상태및 pod 확인
```bash
$ kubectl get node,pod --all-namespaces
NAME              STATUS   ROLES           AGE   VERSION
node/k8s-master   Ready    control-plane   58m   v1.27.4
node/k8s-worker   Ready    <none>          58m   v1.27.4

NAMESPACE          NAME                                           READY   STATUS    RESTARTS   AGE
calico-apiserver   pod/calico-apiserver-f5c6c84bc-95thw           1/1     Running   0          57m
calico-apiserver   pod/calico-apiserver-f5c6c84bc-j64hj           1/1     Running   0          57m
calico-system      pod/calico-kube-controllers-6849ccfdfc-4vfsg   1/1     Running   0          57m
calico-system      pod/calico-node-ldgjw                          1/1     Running   0          57m
calico-system      pod/calico-node-slrtj                          1/1     Running   0          57m
calico-system      pod/calico-typha-7dcd5d784c-dnmzn              1/1     Running   0          57m
calico-system      pod/csi-node-driver-nk67l                      2/2     Running   0          57m
calico-system      pod/csi-node-driver-svpr4                      2/2     Running   0          57m
default            pod/dpl-nginx-777d8c7fbc-qjpkl                 1/1     Running   0          57m
kube-system        pod/coredns-5d78c9869d-jj6jf                   1/1     Running   0          58m
kube-system        pod/coredns-5d78c9869d-p65k9                   1/1     Running   0          58m
kube-system        pod/etcd-k8s-master                            1/1     Running   5          58m
kube-system        pod/kube-apiserver-k8s-master                  1/1     Running   5          58m
kube-system        pod/kube-controller-manager-k8s-master         1/1     Running   5          58m
kube-system        pod/kube-proxy-2vbg6                           1/1     Running   0          58m
kube-system        pod/kube-proxy-rhv59                           1/1     Running   0          58m
kube-system        pod/kube-scheduler-k8s-master                  1/1     Running   5          58m
tigera-operator    pod/tigera-operator-5f4668786-22lwc            1/1     Running   0          57m

```
* firewalld 활성화시 포트 추가
```bash
$ firewall-cmd --add-port=179/tcp --permanent
$ firewall-cmd --add-port=4789/udp --permanent
$ firewall-cmd --add-port=5473/tcp --permanent
$ firewall-cmd --add-port=443/tcp --permanent
$ firewall-cmd --add-port=6443/tcp --permanent
$ firewall-cmd --add-port=2379/tcp --permanent
$ firewall-cmd --reload
```
<br>

### CNI Plugin - Flannel 사용 시
* Master, Worker 전체에서 작업 필요

* /run/flannel/subnet.env 설정
```bash
mkdir -p /run/flannel/

echo "FLANNEL_NETWORK=10.244.0.0/16" >> /run/flannel/subnet.env
echo "FLANNEL_SUBNET=10.244.1.0/24 " >> /run/flannel/subnet.env
echo "FLANNEL_MTU=1450" >> /run/flannel/subnet.env
echo "FLANNEL_IPMASQ=true" >> /run/flannel/subnet.env
```
>cat /run/flannel/subnet.env
```bash
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.0.1/24
FLANNEL_MTU=1410
FLANNEL_IPMASQ=true
```
<br>

* Containerd, Kubelet 재시작
```bash
systemctl restart containerd
systemctl restart kubelet
```
<br>

* Node 상태및 pod 확인
```bash
 $ kubectl get node,pod --all-namespaces

NAME              STATUS   ROLES           AGE   VERSION
node/k8s-master   Ready    control-plane   50s   v1.27.4
node/k8s-worker   Ready    <none>          26s   v1.27.4

NAMESPACE      NAME                                     READY   STATUS    RESTARTS   AGE
kube-flannel   pod/kube-flannel-ds-72ntj                1/1     Running   0          23s
kube-flannel   pod/kube-flannel-ds-kbl6j                1/1     Running   0          23s
kube-system    pod/coredns-5d78c9869d-f422j             1/1     Running   0          32s
kube-system    pod/coredns-5d78c9869d-lwd4s             1/1     Running   0          32s
kube-system    pod/etcd-k8s-master                      1/1     Running   6          43s
kube-system    pod/kube-apiserver-k8s-master            1/1     Running   6          48s
kube-system    pod/kube-controller-manager-k8s-master   1/1     Running   6          43s
kube-system    pod/kube-proxy-c72xf                     1/1     Running   0          32s
kube-system    pod/kube-proxy-j5mb7                     1/1     Running   0          26s
kube-system    pod/kube-scheduler-k8s-master            1/1     Running   6          47s
```

## kubectl 자동완성 설정 

```bash
sudo apt-get install bash-completion -y
source /usr/share/bash-completion/bash_completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source /usr/share/bash-completion/bash_completion
```
* 완료 후, 터미널 다시 접속
