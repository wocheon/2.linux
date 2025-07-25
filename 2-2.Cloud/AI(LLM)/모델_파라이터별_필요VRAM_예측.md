#  모델 파라미터 수에 따른 GPU VRAM 추정 공식 및 데이터 타입 개념 정리

## 기본 개념

* **모델 파라미터(Parameter)**
    - AI 모델을 구성하는 학습 가능한 **가중치(weight)** 수.
    - 예) 2.3B 파라미터 모델 = 약 23억 개의 weight.

* **VRAM (GPU 메모리)**
  - GPU가 AI 모델을 로드하고 실행하는 데 필요한 **그래픽 메모리 용량**.
  - 파라미터를 저장하고, 중간 계산 결과(activations), 옵티마이저 상태 등을 담기 위해 필요.


## 데이터 타입(Precision)과 의미
-  **데이터 타입을 지정한다 = 모델 내부 숫자(텐서)를 GPU 메모리에 어떤 형식으로 저장·계산할지 결정하는 것.**

### 주요 사용되는 데이터 타입 목록
| 데이터 타입          | 1개 값당 메모리 | 특징                       | 주로 쓰는 경우               |
| --------------- | --------- | ------------------------ | ---------------------- |
| FP32 (float32)  | 4 bytes(32 bits)   | 정밀도 높음, 메모리 많이 사용        | 디버깅, 안정적인 학습           |
| FP16 (float16)  | 2 bytes(16 bits)   | 메모리 절약, 연산 빠름            | 추론, Mixed Precision 학습 |
| BF16 (bfloat16) | 2 bytes(16 bits)   | FP16과 같은 메모리, 더 넓은 표현 범위 | 대규모 학습, 최신 GPU         |

**✔️ 데이터 타입은 값의 범위를 지정하는 것이 아니라, 그 값을 메모리에 어떻게 인코딩할지(저장 형식)를 정하는 것.**


### GPU 메모리에 실제로 저장되는 것들

| 저장 대상                         | 설명                   | 데이터 타입 적용                    |
| ----------------------------- | -------------------- | ---------------------------- |
| **모델 파라미터 (Weights, Biases)** | 신경망의 학습된 값           | FP16/FP32/BF16 지정 가능         |
| **중간 계산 결과 (Activations)**    | 레이어별 출력값, KV Cache 등 | FP16으로 저장해 메모리 절약            |
| **옵티마이저 상태 (학습 시)**           | 모멘텀, 그래디언트 등         | Mixed Precision에서 FP32 유지하기도 |


<br>

## 모델 파라미터 별  VRAM 추정 공식
- 추론 시 활성값(activations), 중간값, KV Cache 등 추가 메모리 필요.
    -  **실제 필요 VRAM**은 파라미터 메모리의 약 **1.3 \~ 1.5배**로 잡는 것을 권장.
- 학습 시에는 그래디언트, 옵티마이저 상태 등 추가 메모리 필요.    
    - → 보통 파라미터 메모리의 **3배 이상** 필요.


``` sh
# 파라미터 메모리 크기 (Bytes)
파라미터 수 × 1 파라미터당 메모리 크기

# 파라미터 메모리 크기 (GB)
(파라미터 수 × 1 파라미터당 메모리 크기) ÷ (1024³)

# 추론 시 필요 VRAM 계산 식
VRAM_추론 ≈ 파라미터 메모리 × (1.3 ~ 1.5)

# 학습 시 필요 VRAM 계산 식
VRAM_학습 ≈ 파라미터 메모리 × 3
```

#### EX) 8.8B 파라미터 모델

| Precision           | 파라미터 메모리 (GB) | 추론 VRAM (GB) | 학습 VRAM (GB) |
| ------------------- | ------------- | ------------ | ------------ |
| FP16/BF16 (2 bytes) | 17.6          | 22.9 \~ 26.4 | 약 53 이상      |
| FP32 (4 bytes)      | 35.2          | 45.8 \~ 52.8 | 약 106 이상     |



## 추가 참고 사항

* 배치 크기, 시퀀스 길이, 모델 구조 등에 따라 실제 VRAM 요구량은 달라질 수 있음.
* FP16과 BF16은 메모리 소모량은 같지만 연산 방식과 안정성에 차이가 있음.
* 실제 사용 시에는 여유 있는 VRAM 계획이 필요.


### 딥러닝에서 자주 쓰이는 데이터 타입

- FP32/FP16/BF16이 훈련과 추론에서 표준적으로 지원되고, 가장 많이 쓰이는 타입
    - INT8, INT4 등은 양자화(Quantization) 를 적용한 특수한 경우
    - TF32나 FP8은 특정 GPU 세대에서만 지원하거나 아직 실험적인 영역이 많음 

| 데이터 타입              | 크기          | 특징                             | 사용 예                 |
| ------------------- | ----------- | ------------------------------ | -------------------- |
| **FP32 (float32)**  | 32bit (4B)  | 높은 정밀도, 가장 표준적                 | 전통적인 학습/추론           |
| **FP16 (float16)**  | 16bit (2B)  | 메모리 절약, 빠른 연산                  | Mixed Precision, 추론  |
| **BF16 (bfloat16)** | 16bit (2B)  | FP16과 같은 메모리, 더 넓은 표현범위        | 대규모 학습, TPU/A100     |
| **INT8**            | 8bit (1B)   | 정수형, 메모리 매우 적음, 속도 빠름          | 양자화 추론(Quantization) |
| **INT4**            | 4bit (0.5B) | 극단적 메모리 절약, 정밀도 손해             | LLM 양자화 추론           |
| **TF32**            | 내부적으로 19bit | NVIDIA Ampere 계열 전용, FP32보다 빠름 | 학습 가속 (A100 등)       |
| **FP8**             | 8bit (1B)   | 차세대 표준, 메모리 절약/성능 균형           | 최신 H100 GPU 지원       |
