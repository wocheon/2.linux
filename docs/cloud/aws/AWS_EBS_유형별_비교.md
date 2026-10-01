# AWS EBS 유형별 비교

EBS는 EC2용 블록 스토리지입니다. 실제 성능과 가격은 볼륨 크기, 프로비저닝 값, 인스턴스·리전 제한에 따라 달라집니다.

|유형|권장 용도|선택 시 주의|
|---|---|---|
|gp3|일반 SSD, 부팅·애플리케이션·대부분의 DB|용량과 IOPS/처리량을 분리해 설정 가능|
|gp2|기존 범용 SSD 볼륨|성능이 용량과 연동됨. 신규 구성은 gp3와 비교|
|io2|높은 IOPS와 내구성이 필요한 DB|지원 인스턴스와 provisioned IOPS 확인|
|io1|기존 고성능 SSD 볼륨|신규 구성은 io2와 비교|
|st1|순차 읽기·쓰기 중심의 대용량 처리|부팅 볼륨 불가, 작은 랜덤 I/O에 부적합|
|sc1|드문 접근의 대용량 데이터|부팅 볼륨 불가, 낮은 처리량|
|Magnetic (standard)|기존 볼륨 유지|레거시 유형으로 신규 생성은 다른 유형 검토|

비용·상한을 고정된 숫자로 비교하지 않고 [AWS EBS 유형별 특성](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-io-characteristics.html)과 [EBS 볼륨 유형](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html)에서 대상 리전·인스턴스를 확인합니다.
