# K3S 설치 및 사용 (수정중)

- 간단한 쿠버네티스 환경 구축 혹은 테스트가 필요한 경우 사용
- 단일 VM에 설치하여 쿠버네티스를 사용가능 
- 경량화 버전이므로 k8s 모든기능은 다 포함되지않음
- 기본적으로 containerd를 내장하고 있어서 별도의 Docker 설치 없이도 컨테이너를 실행 가능 

### k3s 설치 

```bash
curl -sfL https://get.k3s.io | sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
```

##  k3s 환경에 helm chart 배포
- 쿠버네티스 환경이므로 Helm chart도 배포할수 있음 

### 스크립트를 통해 Helm 설치
```bash
 curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
 chmod 755 get_helm.sh
 ./get_helm.sh
```

### KUBECONFIG 환경변수 설정 
- K3s는 기본적으로 API 서버를 localhost:8080이 아닌 /etc/rancher/k3s/k3s.yaml에 정의된 설정(일반적으로 포트 6443)으로 실행
- Helm과 kubectl이 올바른 kubeconfig를 참조하도록 환경 변수를 설정
```bash
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
source ~/.bashrc
```

### repo 등록 후 차트 배포 

- helm에 argoCD repository 추가
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

- 차트 배포
```bash
$ helm upgrade --install argocd argo/argo-cd 
```

# MetalLB 설치 
- Loadbalancer 서비스의 External_IP 가 Pending 상태에서 넘어가지 않는 현상 발생
- K3s와 같은 경량 Kubernetes 배포판에서는 MetalLB 같은 로드 밸런서 솔루션이 필요