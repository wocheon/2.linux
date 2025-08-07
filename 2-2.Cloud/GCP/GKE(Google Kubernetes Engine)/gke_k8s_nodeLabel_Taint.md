# GKE 클러스터 내 Node Scheduling 관리: Node Label/Taint 

## Kubernetes에서 Label과 Taint의 역할 및 차이점

### Kubernetes Label (라벨)
- 노드에 key-value 형태로 붙임.
- Pod 내 `nodeSelector` 또는 `nodeAffinity`를 사용해 특정 라벨이 붙은 노드에만 Pod가 스케줄링되도록 지정.
- “특정 노드에 Pod를 *끌어당기는* 역할”을 함.
- 주로 Pod를 배치하고자 하는 노드 그룹을 명확히 지정하는 데 사용.

### Taint (테인트)
- 노드에 **일종의 ‘배제 표시’**를 달아 기본적으로 아무 Pod도 스케줄되지 않도록 함.
- Pod는 해당 taint를 무시할 수 있도록 `toleration`을 설정해야만 그 노드에 배치 가능.
- “아무나 오지 못하게 *막는* 역할”을 함.
- 중요 노드(GPU 노드 등)에 일반 워크로드가 실수로 배치되는 것을 방지하는 데 유용.

### Label과 Taint를 함께 사용하는 이유
- Label만 사용 시: Pod를 원하는 노드로 끌어당기기는 하나, 실수로 다른 Pod가 올라올 수 있음.
- Taint만 사용 시: 노드에 Pod가 무조건 올라가진 않지만, 어떤 Pod가 오게 할지는 라벨 지정만으로 관리 어려움.
- **두 가지를 같이 사용하면 특정 Pod를 원하는 노드에 스케쥴링 하도록 하고, Pod가 다른 노드에 잘못 배치되는 것을 방지할수 있음**


## Taint/Node Label을 통한 GKE Node Auto-Scale Schedule 구성

### Scale-out
- 08:30에 GPU 사용 Pod의 replica를 조정하여 Pod를 배포함.
- 노드풀별로 Taint가 설정되어 있으며, 노드 자동 확장기능(Autoscaler)이 있어서 필요한 노드가 자동으로 생성되고 Pod가 배포됨.

### Scale-in
- 19:00에 GPU 사용 Pod replica를 0으로 조정.
- Pod가 사라지면 해당 노드에 남은 Pod가 없어짐.
- GKE의 Cluster Autoscaler가 작동하여 유휴 상태인 노드를 자동으로 삭제함.
    - GKE의 경우 기본 idle 간주 시간(scale-down-unneeded-time)은 10분 이므로 약 10분간 다른 Pod가 스케일링 되지않으면 자동으로 노드 삭제

### 핵심 요약
- GPU 노드에 Taint가 붙어 있어서, 일반 Pod가 해당 노드에 배치되지 않음.
- GPU Pod가 replica 0이 되면 노드가 유휴 상태가 되고, Cluster Autoscaler가 해당 노드를 삭제함.
- 이를 통해 비용 효율적으로 GPU 노드를 운용 가능.
