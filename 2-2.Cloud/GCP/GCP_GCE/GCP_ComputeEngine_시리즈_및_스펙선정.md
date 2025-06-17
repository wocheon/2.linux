# GCP Compute Engine 시리즈 및 스펙 선정 

## 코어 비율 변경 관련 

- 인텔 프로세서 기준 1 코어당 2개의 vCPU를 가지며 코어당 vCPU 비율을 변경 가능 
    - 코어당 vCPU 1 개로 변경가능
        - H3 시리즈 , 공유코어 머신 (g1-small, f1-micro) , vCPU 2개 미만의 경우 비율 변경 불가능

    - Intel 프로세서 기준 하이퍼 스레딩 기술(HTT)이라고 부르는 동시 멀티스레딩(SMT)을 통해 CPU 코어가 2개의 하드웨어 멀티스레드로 실행

    - Compute Engine에서 각 가상 CPU(vCPU)는 단일 하드웨어 멀티스레드로 구현되며 두 vCPU는 기본적으로 각각의 물리적 CPU 코어를 공유
    

- 일부 AMD 아키텍처 및 ARM 아키텍처(T2A, T2D)의 경우 1코어당 2개의 vCPU를 가지는 것으로 고정


### 비율 변경시 주의사항
- 메뉴얼 상에는 vCPU를 기준으로 비용책정이된다고 되어있으나 실제로는 코어를 기준으로 비용이 책정된다고 보면됨.

>ex)
- n2-standard-8 ( 4core 8GB mem) 머신은 기본적으로 코어당 2개의 vCPU를 가지므로 최대 8개의 vCPU를 가질 수있음.
- 코어 당 vCPU 비율을 1개로 변경 시, 4개의 vCPU를 가질 수있음
- 코어 비율을 변경하여 4개의 vCPU만 사용하더라도 8개의 vCPU를 가진 머신을 사용하는 비용을 지불해야함

- 커스텀 머신 사용시 
    - vCPU : 16 / Ram : 80GB / 코어당 vCPU : 1  = vCPU : 32 / Ram : 80GB / 코어당 vCPU : 2 
    - 결국 코어당 1개의 vCPU를 사용하여 16vCPU만 사용해도 32 vCPU 의 비용을 지불해야함

### CPU 세대 선택 
- 인텔 프로세서의 경우 각 시리즈 별로 사용가능 한 CPU 플랫폼(세대)를 선택 가능 
    - E2 시리즈의 경우 가용성 기준이므로 선택이 불가능 

- 추가적으로 비용은 발생하지 않음

- 커스텀 머신 또한 선택한 시리즈 별로 CPU 플랫폼 선택 가능


## 머신 시리즈 
- 참고 
    - [GCP 머신 시리즈 정리](https://cloud.google.com/compute/docs/machine-resource?hl=ko)
    - [GCP 비용 계산기](https://cloud.google.com/products/calculator?hl=ko)

### GCP 세대별 머신 시리즈 
|세대|Intel|AMD|Arm|
|:-:|:-:|:-:|:-:|
|1세대 머신 시리즈|	N1, M1|||		    
|2세대 머신 시리즈|	E2, N2, C2, M2, A2, G2|	N2D, C2D, T2D, E2|	T2A|
|3세대 머신 시리즈|	M3, C3, H3, A3|	C3D	||


- 시리즈 별로 사용가능한 vCPU, Memory, SSD용량이 다르며 네트워크 성능도 차이가 있으므로 <br>
  용도에 따라 머신 시리즈를 선택할 것 

- `M2`, `M3`, `H3` 머신 계열을 제외한 모든 머신 계열은 스팟 VM(및 선점형 VM)을 지원

- `N1`, `A2`, `G2` 시리즈는 GPU를 사용가능 
    - `A2`, `G2`는 VM 생성시 자동으로 GPU 연결됨
    - 일반적으로 GPU 수가 많을수록 더 많은 vCPU와 높은 메모리 용량으로 VM을 만들 수 있다


## 할인 지원 
- 계속 실행중인 상태로 유지되는 VM의 경우 약정등을 통해 비용 할인을 받을 수 있음
- 할인적용순서 
    - 리소스 기반 CUD => 가변형 CUD => SUD

### CUD - Commited Use Discounts
 - 1년 또는 3년 동안 약정된 금액을 지불하는 조건으로 리소스를 할인된 가격으로 구매하는 할인 방법

 - 1년 보다 3년 약정의 할인율이 높음

 - 리전마다 할인율 상이 
 


- 리소스 기반 CUD
    -  특정 리전에서 최소한 일정 수준의 Compute Engine 리소스를 사용한다는 약정의 대가로 할인을 제공

    - 사용량이 예측 가능하고 안정적인 상태일 때 이상적인 옵션

    - 소프트웨어 약정 및 하드웨어 약정을 제공

    - 참고 
        - [리소스 기반 CUD](https://cloud.google.com/compute/docs/instances/committed-use-discounts-overview?hl=ko#resource_based)

- 가변형 CUD (지출기반 CUD)
    -  1년 또는 3년 동안 Compute Engine vCPU 또는 메모리에 대해 시간당 최소 지출 금액을 약정하는 방식

    - [가변형 CUD](https://cloud.google.com/compute/docs/instances/committed-use-discounts-overview?hl=ko#spend_based)

### SUD - Sustained Use Discounts
- 지속 사용 할인

    - 청구 월의 25% 이상 사용되고 다른 할인을 받지 못하는 리소스에 대해 지속 사용 할인(SUD)을 제공
    - 사용량이 늘어날수록 할인이 점진적으로 증가
        - 한달 내내 실행된 가상 머신(VM)의 경우 리소스 비용에서 최대 30%의 순 할인을 받을 수 있다

- 참고 
    - [지속사용할인](https://cloud.google.com/compute/docs/sustained-use-discounts?hl=ko)


### 시리즈별 할인 지원 목록

|시리즈|지속사용 할인|리소스 기반 CUD|가변형 CUD|스팟 VM 할인|
|:-:|:-:|:-:|:-:|:-:|
|E2||O|O|O|
|N1|O|O|O|O|
|N1+GPU|O|O||O|
|N2|O|O|O|O|
|N2D|O|O|O|O|
|M1|O|O||O|
|M2|O|O|||
|M3||O|||
|C2|O|O|O|O|
|C3||O|O|O|
|C2D||O|O|O|
|C3D||O||O|
|T2D||O||O|
|T2A||||O|
|H3||O|||
|A2||O||O|
|G2||O||O|
