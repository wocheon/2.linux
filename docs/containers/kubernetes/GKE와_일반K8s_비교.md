# GKE와 일반 Kubernetes 클러스터 비교

여기서 일반 Kubernetes는 VM에 `kubeadm`으로 직접 설치한 클러스터를 뜻합니다.

|항목|직접 설치한 Kubernetes|GKE Standard|GKE Autopilot|
|---|---|---|---|
|Control plane|사용자가 설치·업그레이드·관리|Google Cloud가 관리|Google Cloud가 관리|
|Worker node|사용자가 생성·패치·교체|사용자가 노드 풀을 설정, GKE의 자동 업그레이드·복구 기능 사용 가능|Google Cloud가 노드를 프로비저닝·관리|
|CNI·네트워크|직접 선택·설치|GKE 네트워크 기능과 설정 사용|GKE의 사전 구성된 네트워크 기능 사용|
|확장·유지보수|직접 구성|노드 풀·클러스터 설정을 사용자가 선택|워크로드 요구에 맞춰 자동 처리|
|비용 기준|VM·네트워크·스토리지와 운영 부담|노드 자원 및 클러스터 관리 요금|Pod 요청 자원 중심의 모델|

## 선택 기준

- 설치 과정과 CNI·control plane을 직접 학습하려면 [kubeadm 테스트](K8s_Cluster_구축.md)가 적합합니다.
- GCP 서비스 연동과 노드 구성의 제어가 필요하면 GKE Standard를 검토합니다.
- 노드 운영을 줄이려면 GKE Autopilot을 검토합니다. 제약과 요금은 배포 전 확인합니다.

참고: [GKE 개요](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview), [GKE 클러스터 구조](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture), [Autopilot 개요](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview), [kubeadm 클러스터 생성](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
