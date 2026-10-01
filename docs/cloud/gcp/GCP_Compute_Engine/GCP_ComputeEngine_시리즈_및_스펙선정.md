# GCP Compute Engine 시리즈 및 스펙 선정

머신 시리즈와 지원 리전·GPU·할인 정책은 수시로 바뀌므로 고정 세대/할인 표 대신 공식 목록을 기준으로 선택합니다.

## 워크로드별 선택

|용도|먼저 살펴볼 머신 계열|확인할 항목|
|---|---|---|
|일반 서비스·테스트|E2, N4/N4D 등|vCPU/메모리, 지역, 가격|
|CPU 집약|C4/C4A/C4D, H4D 등|프로세서, 네트워크, 로컬 SSD|
|메모리 집약|M4/M4N, X4 등|메모리 용량과 리전|
|GPU·AI|A4/A4X, G4 또는 N1+GPU 등|GPU 종류·개수, 할당량, 리전|
|Arm 워크로드|T2A 등 Arm 계열|이미지·애플리케이션 아키텍처 호환성|

숫자가 높은 시리즈가 모든 워크로드에서 더 저렴하거나 빠른 것은 아닙니다. [공식 머신 계열 비교](https://cloud.google.com/compute/docs/machine-resource)에서 후보를 고른 뒤 [GPU 지원 유형](https://cloud.google.com/compute/docs/gpus), [가격 계산기](https://cloud.google.com/products/calculator)로 실제 구성을 비교합니다.

## 코어당 스레드와 비용

일부 머신 계열은 코어당 스레드 수(1 또는 2)를 변경할 수 있습니다. 지원 여부·청구 단위는 계열별로 다르므로 [코어당 스레드 설정](https://cloud.google.com/compute/docs/instances/set-threads-per-core)과 가격 계산기에서 확인합니다. `n2-standard-8`의 메모리는 32 GiB이며, 8 GiB가 아닙니다.

## 할인 및 디스크

약정 사용 할인(CUD), 지속 사용 할인(SUD), Spot VM 할인은 계열과 상품별 자격이 다릅니다. 기존 표의 일괄 `O/X` 값은 사용하지 않습니다. [CUD](https://cloud.google.com/compute/docs/instances/committed-use-discounts-overview), [SUD](https://cloud.google.com/compute/docs/sustained-use-discounts), [Spot VM](https://cloud.google.com/compute/docs/instances/spot)를 각각 확인합니다. 디스크 선택은 [Persistent Disk·Hyperdisk·Local SSD 비교](../GCP_PersistentDisk_로컬SSD차이.md)를 참고합니다.
