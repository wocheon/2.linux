# Kubernetes 클러스터 구축 (kubeadm)

Ubuntu 24.04 LTS 기준 단일 control plane 테스트 구성입니다. VMware Workstation과 GCP VM에 같은 설치 절차를 사용합니다. RHEL 계열 VM은 CentOS 7 대신 Rocky Linux 9를 사용합니다.

## 환경별 준비

|항목|VMware Workstation|GCP VM|
|---|---|---|
|노드 IP|고정 사설 IP 설정|동일 VPC의 내부 IP 사용|
|노드 간 통신|가상 네트워크에서 허용|VPC 방화벽에서 노드 간 통신 허용|
|추가 설정|복제한 VM의 hostname·IP 재설정|VM 서비스 계정·방화벽 확인|

각 노드는 최소 2 GiB RAM을 확보하고, control plane은 2 CPU 이상을 사용합니다. 아래의 `CONTROL_PLANE_IP`와 Pod CIDR은 실제 네트워크와 겹치지 않도록 바꿉니다.

## 전체 노드: containerd와 Kubernetes 설치

```bash
sudo swapoff -a
# 재부팅 후에도 swap이 켜지지 않도록 /etc/fstab의 swap 항목을 비활성화합니다.
sudo modprobe overlay
sudo modprobe br_netfilter
printf 'overlay\nbr_netfilter\n' | sudo tee /etc/modules-load.d/k8s.conf
printf 'net.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\n' \
  | sudo tee /etc/sysctl.d/k8s.conf
sudo sysctl --system
sudo apt-get update
sudo apt-get install -y containerd ca-certificates curl gpg
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd
sudo systemctl restart containerd

KUBERNETES_MINOR=v1.37
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/deb/Release.key" \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

Rocky Linux 9은 [Kubernetes의 RPM 저장소 설치 절차](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)와 `containerd.io`를 사용합니다. OS에 관계없이 containerd의 CRI와 `SystemdCgroup = true`를 확인합니다.

## control plane 초기화

```bash
CONTROL_PLANE_IP=10.0.0.10 # 실제 control plane 내부 IP
sudo kubeadm init --apiserver-advertise-address "$CONTROL_PLANE_IP" --pod-network-cidr=192.168.0.0/16
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
```

Pod CIDR `192.168.0.0/16`은 Calico 기본값입니다. GCP VPC 또는 VMware 네트워크와 겹치면 `kubeadm init`의 CIDR과 Calico의 IP pool을 함께 변경합니다.

## Pod 네트워크와 Worker 연결

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/v1_crd_projectcalico_org.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/custom-resources.yaml
kubectl get nodes
```

Worker에서 `kubeadm init` 출력의 `sudo kubeadm join ...` 명령을 실행합니다. 토큰이 만료됐다면 control plane에서 `sudo kubeadm token create --print-join-command`로 새 명령을 발급합니다.

참고: [kubeadm 설치](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/), [클러스터 생성](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/), [Calico 설치](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)
