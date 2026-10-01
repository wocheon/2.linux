# Kubernetes CNI 정리

## CNI 별 특징 정리

|Provider|Network<br>Model|Route<br>Distribution|Network<br>Policy|Mesh|External<br>Database|Encryption|Ingress/Egress<br>Policies|Commercial<br>Support|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:
|Calico|Layer 3|Yes|Yes|Yes|Etcd|Yes|Yes|Yes|
|Canal|Layer 2<br>vxlan|N/A|Yes|No|Etcd|No|Yes|No|
|Flannel|vxlan|No|No|No|None|No|No|No|
|kopeio-networking|Layer 2|N/A|No|No|None|Yes|No|No|
|kube-router|Layer 3|BGP|Yes|No|No|No|No|No|
|romana|Layer 3|OSPF|Yes|No|Etcd|No|Yes|Yes|
|Weave Net|Layer 2<br>vxlan|N/A|Yes|Yes|No|Yes|Yes|Yes|


## GCP에서 사용가능한  CNI Plugin 

### Kubenet 
- 가장 기본적인 네트워크 플러그인
- 추가기능 제공 x (네트워크 정책, 암호화)
- GKE에서 CNI 플러그인 미선택 시 기본적으로 선택되는 네트워크 플러그인 (Default)

### Calico
- 가장 대중적으로 사용되는 K8S CNI 플러그인
- Network policy 등의 보안기능 제공
- 준수한 성능 
- GKE의 VPC-native mode, Alias IP 등의 기능과 통합되어있으므로<br> GKE의 Network policy 기능 사용 시 기본적으로 선택되는 CNI 플러그인


* Cilium
- GKE - Dataplane V2 
- 강력한 Network policy와 암호화를 제공
- network visibility 기능으로 높은 투명성을 제공
- 큰 사이즈의 클러스터를 타겟으로 한 CNI 플러그인


 ## GKE vs GCE를 사용한 Self-managed cluster 환경(with Calico)
- GKE보다 전체적으로 성능이 낮음.
- 자원 소모량 큰 차이 없음.
- `성능 및 자원 및 관리적 측면으로 보아 k8s 운영에는 GKE가 더 유리함.`
