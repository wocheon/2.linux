# LLM 모델 포맷



### **주요 모델 포맷 및 SW 매핑 차트**

| 포맷 이름 (확장자/태그) | **주 용도 및 특징** | **추천 실행 SW** | **하드웨어** | **비고 (엔지니어 팁)** |
| :--- | :--- | :--- | :--- | :--- |
| **GGUF**<br>`*.gguf` | **로컬/개인용 표준**<br>CPU/Mac 최적화, 단일 파일이라 관리가 매우 편함. | **Ollama**<br>**LM Studio**<br>llama.cpp | **Apple Silicon**<br>저사양 GPU<br>CPU Only | 허깅페이스에서 다운받을 때 파일명에 `Q4_K_M`, `Q5_K_M` 붙은 걸 받으세요. (가성비 최고) |
| **AWQ**<br>`*-awq` | **GPU 추론 표준**<br>압축률 좋고 GPU 연산 속도가 매우 빠름. | **vLLM**<br>Text-Gen-WebUI<br>HuggingFace | **NVIDIA GPU** | vLLM 서버 돌릴 때 가장 권장합니다. GPTQ보다 빠르고 설정이 쉽습니다. |
| **GPTQ**<br>`*-gptq` | **구형 GPU 표준**<br>AWQ 이전에 많이 쓰임. 여전히 호환성은 가장 넓음. | **vLLM**<br>Text-Gen-WebUI<br>AutoGPTQ | **NVIDIA GPU** | 최신 모델은 AWQ로 넘어가는 추세지만, 아직 많은 구형 모델이 GPTQ로 배포됩니다. |
| **Safetensors**<br>`*.safetensors` | **원본(Unquantized)**<br>보안성이 높고 로딩 속도가 빠른 **사실상의 표준 원본 포맷**. | **vLLM**<br>HuggingFace<br>모든 파이썬 코드 | **고성능 GPU**<br>(VRAM 24GB+) | `pytorch_model.bin`의 대체재입니다. 피클(pickle) 해킹 위험이 없어 안전합니다. |
| **PyTorch Bin**<br>`*.bin` | **구형 원본**<br>예전 방식. 보안 문제(Pickle)로 Safetensors로 대체되는 중. | **vLLM**<br>PyTorch<br>Transformers | **고성능 GPU** | 요즘 나오는 모델은 대부분 Safetensors로 배포되므로 굳이 찾아서 쓸 필요 없습니다. |
| **ONNX**<br>`*.onnx` | **호환성/배포용**<br>서로 다른 프레임워크 간 변환용이나 경량화 배포용. | ONNX Runtime<br>Triton Server | CPU / GPU<br>NPU | 주로 모바일 앱이나 웹 브라우저(WebAssembly)에서 AI 돌릴 때 씁니다. |

***

### **🚀 AI 모델 서빙 & 학습 시나리오별 가이드 (The Definitive Guide)**

#### **Situation A: "회사 서버에 올려서 고성능 서비스 할 거야" (Production Serving)**
> **핵심 목표**: 대규모 동시 접속 처리(Concurrency), 짧은 응답 지연(Latency), GPU 효율 극대화

*   **추천 모델 포맷**: **AWQ** (권장) 또는 **GPTQ**
    *   *검색 키워드*: `Llama-3-8B-Instruct-AWQ`
*   **실행 SW**: **vLLM** (압도적 1순위)
    *   *대안*: TensorRT-LLM (엔비디아 찐 최적화가 필요할 때)
*   **추천 OS**: **Linux (Ubuntu 22.04 LTS)**
    *   Windows는 프로덕션 서버로 절대 비추천 (GPU 드라이버 오버헤드 및 스케줄링 비효율)
*   **실행 방식**: **Docker Container**
    *   *Why?* vLLM과 CUDA 버전의 의존성이 매우 민감하므로, 호스트를 더럽히지 않고 공식 이미지를 쓰는 것이 정신 건강에 이롭습니다.
*   **권장 하드웨어**: NVIDIA Data Center GPU (A100, H100, L4) 또는 High-end Consumer GPU (RTX 4090)

#### **Situation B: "내 맥북이나 집 PC에서 혼자 갖고 놀 거야" (Local Playground)**
> **핵심 목표**: 간편한 설치, 저전력, RAM 용량 내 실행, 직관적인 UI

*   **추천 모델 포맷**: **GGUF**
    *   *검색 키워드*: `Llama-3-8B-Instruct-GGUF` (파일: `Q4_K_M.gguf` 추천)
*   **실행 SW**:
    *   **개발자라면**: **Ollama** (터미널/API 접근 용이)
    *   **비개발자라면**: **LM Studio** (채팅 UI 제공)
*   **추천 OS**: **Mac (macOS)** 또는 **Windows 11**
    *   Mac은 Apple Silicon(M1/M2/M3)의 통합 메모리 덕분에 AI 구동에 최적입니다.
*   **실행 방식**: **Native App (설치형 프로그램)**
    *   *Why?* 개인 PC에서는 Docker의 오버헤드나 포트 포워딩 설정조차 귀찮습니다. 그냥 `.exe`나 `.dmg`로 설치해서 클릭 한 번으로 켜는 게 최고입니다.

#### **Situation C: "모델 연구/파인튜닝(Fine-tuning)을 할 거야" (Research & Training)**
> **핵심 목표**: 모델 가중치 수정 가능성, 학습 라이브러리 호환성, 실험 재현성

*   **추천 모델 포맷**: **Safetensors** (원본 FP16/BF16)
    *   *검색 키워드*: `Llama-3-8B-Instruct` (뒤에 아무것도 안 붙은 것)
    *   *주의*: QLoRA를 쓰더라도 원본을 받아서 로드 시점에 4bit로 변환(On-the-fly quantization)하는 것이 정석입니다.
        - 양자화 모델은 미세한 변화를 기록할 공간이 없으므로 기울기 소실 혹은 폭발로 인해 모델이 멍청해짐
*   **실행 SW**: **PyTorch** + **Hugging Face Transformers** (+ PEFT/BitsAndBytes)
    *   *프레임워크*: **Unsloth** (학습 속도 2배 빠르고 메모리 절약됨, 강력 추천), Axolotl
*   **추천 OS**: **Linux (Ubuntu)** 또는 **Windows (WSL2)**
    *   학습용 라이브러리(DeepSpeed, BitsAndBytes)는 윈도우 네이티브에서 설치가 매우 고통스럽습니다. 윈도우라면 무조건 **WSL2**를 쓰세요.
*   **실행 방식**: **Python Virtual Environment (Conda/Venv)**
    *   *Why?* 학습은 실험마다 라이브러리 버전(PyTorch Nightly 등)을 자주 바꿔야 합니다. Docker는 이미지를 계속 다시 빌드해야 해서 번거로울 수 있습니다.

***

### **[요약 매트릭스]**

| 시나리오 | 모델 포맷 | 실행 SW | 추천 OS | 실행 방식 |
| :--- | :--- | :--- | :--- | :--- |
| **서비스 배포** | **AWQ** | **vLLM** | **Linux** | **Docker** (필수) |
| **로컬/개인용** | **GGUF** | **Ollama** / LM Studio | **Mac / Win** | **Native App** |
| **학습/연구** | **Safetensors** | **PyTorch** (Unsloth) | **Linux** / WSL2 | **Conda** (가상환경) |	