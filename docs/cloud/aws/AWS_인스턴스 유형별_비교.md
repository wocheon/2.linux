# AWS EC2 인스턴스 유형별 비교

세대별 CPU·메모리·로컬 디스크 구성은 계속 바뀝니다. 아래는 테스트용 선택 기준이며 실제 지원 여부와 가격은 대상 리전의 공식 목록에서 확인합니다.

|패밀리|대표 계열|선택 기준|
|---|---|---|
|범용|T4g, M8g/M8i 등|T는 버스트형, M은 균형형. 지속 CPU 사용은 크레딧 모델 확인|
|컴퓨팅 최적화|C8g/C8i 등|CPU 집약적 빌드·분석|
|메모리 최적화|R8g/R8i, X, U 등|인메모리 DB·큰 힙|
|스토리지 최적화|I7i/I8g, D 등|로컬 NVMe/HDD 필요 여부 확인|
|가속 컴퓨팅|G6/G7, P5/P6, Trn, Inf, F 등|그래픽·AI 학습/추론·FPGA 등 장치별 선택|

세대 접미사(`g`, `i`, `a`, `d` 등)는 프로세서·로컬 스토리지 구성을 뜻할 수 있지만 계열별로 확인해야 합니다. Graviton은 Arm 기반이므로 x86 전용 바이너리 호환성을 점검합니다. T 계열의 CPU 크레딧은 AWS가 추적하며, Unlimited 모드의 추가 사용에는 과금이 발생할 수 있습니다. 크레딧은 VM 내부 토큰이 아닙니다.

참고: [EC2 인스턴스 유형](https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-types.html), [버스트 성능](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-credits-baseline-concepts.html)
