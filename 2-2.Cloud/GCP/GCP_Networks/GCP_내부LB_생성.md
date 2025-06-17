# GCP 내부 Load Balancer 생성 

## 작업 순서 
1. 인스턴스 그룹 생성 
    - LB 내의 백엔드로 지정하려면 인스턴스 그룹으로 지정해야 가능
    - 기존 VM 에 연결시 => Unmanaged Group으로 설정 필요 

2. helth-check 방화벽 오픈 
    - GCP LB의 경우 helth-check 가 필수적으로 동반되며 <br> helth-check를 통과한 백엔드에만 트래픽을 보내도록 설정되어있음

    - 방화벽에서 helth-check 프로브 IP 범위를 허용해주지 않으면 백엔드서비스는 모두 비정상으로 표기됨 
    
    - 참고 : helth-check 프로브 IP 대역 
        - https://cloud.google.com/load-balancing/docs/health-check-concepts?hl=ko#ip-ranges


3. LB 생성 
- 용도에 따라 LB 생성 
- 예시 
    - 이중화 DB 구성용 LB 생성 
        - 부하분산기 유형 : 내부 패스스루 네트워크 부하 분산기 (TCP/UDP/SSL)

- frontend 및 IP 지정 

- 생성 후  정상 작동 확인 
