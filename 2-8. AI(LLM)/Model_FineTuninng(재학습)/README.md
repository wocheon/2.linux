# Model_FineTuninng(재학습)

간단한 개요
- 이 디렉토리는 한국어 감성 분류용 사전학습 모델을 파인튜닝(재학습)하고, 재학습 모델과 원본 모델을 비교하는 스크립트를 포함합니다.
- 핵심 스크립트: `train.py` (학습), `compare_models.py` (원본 vs 재학습 비교), 보조: `gpu_check.py`

디렉토리 주요 파일
- train.py          : 모델 파인튜닝 실행 스크립트
- compare_models.py : 재학습 모델과 원본 모델을 평가/비교하는 스크립트
- config.ini        : 실행에 필요한 설정 파일 (경로·하이퍼파라미터 등)
- dataset_dir/      : 학습에 사용할 데이터셋 디렉토리 (parquet 형식 사용 예상)
- temp_logs/        : (임시) 평가/로그 저장용 디렉토리
- gpu_check.py      : GPU 사용 가능 여부 체크 스크립트

요구사항
- OS: Windows (개발 환경 기준)
- Python 3.8+
- 권장 라이브러리: transformers, datasets, torch, scikit-learn, numpy, tqdm
- 설치 예:
  - pip install -r requirements.txt
  - (requirements.txt가 없을 경우) pip install transformers datasets torch scikit-learn numpy tqdm

config.ini (필수 키 예시)
- 파일을 프로젝트 루트에 배치해야 함.
- 최소 필요한 항목 예:
```ini
[Path]
model_name = klue/bert-base
train_file = C:\\path\\to\\train.parquet
valid_file = C:\\path\\to\\valid.parquet   ; (선택) 없으면 train에서 자동 분할
output_dir = C:\\path\\to\\output_model
checkpoint_dir = C:\\path\\to\\checkpoints

[Hyperparameters]
num_labels = 2
max_seq_length = 128
batch_size = 16
learning_rate = 5e-5
epochs = 3
seed = 42
split_ratio = 0.1
use_subset = False
subset_size = 100
```

데이터 형식(중요)
- 데이터 파일 형식: parquet
- 기본 예상 컬럼:
  - 텍스트 컬럼: `Review_Text` (스크립트에서 이 컬럼명을 사용합니다 — 다르면 config 또는 코드 수정 필요)
  - 레이블 컬럼: `Label` 또는 `label` (코드에서 `Label`을 `label`로 변경하는 로직 포함)
- 검증 파일이 없으면 `split_ratio` 비율로 학습 데이터에서 자동 분할

사용법 (Windows PowerShell/CMD)
1) 학습 실행
- PowerShell / CMD에서 프로젝트 루트로 이동 후:
  - python train.py
- train.py는 `config.ini`를 읽어 실행합니다.

2) 모델 비교(평가)
- 학습 완료 후 원본 모델과 재학습 모델 비교:
  - python compare_models.py

3) GPU 체크
- python gpu_check.py

핵심 동작 설명 (간단)
- train.py
  - config.ini 로드 → 데이터 parquet 로드(또는 train/validation 파일) → tokenizer 적용 → Trainer로 학습 → output_dir에 최종 모델 저장
  - 테스트용으로 `use_subset=True` 설정하면 데이터 수를 줄여 빠르게 확인 가능
- compare_models.py
  - 동일한 전처리로 검증셋 준비 → 원본 모델(모델명)과 재학습 모델(output_dir)을 불러와 평가(accuracy, f1) → 차이 출력

팁 및 주의사항
- 모델 이름(MODEL_NAME)은 HuggingFace 허브의 식별자 또는 로컬 체크포인트 경로가 될 수 있음.
- 데이터 컬럼명이 다르면 train.py와 compare_models.py의 preprocess_function에서 컬럼명을 수정해야 함.
- 학습 시 메모리(GPU VRAM) 부족 문제가 발생하면 `batch_size`나 `max_seq_length`를 낮추세요.
- 체크포인트 및 출력 경로는 config.ini에서 절대경로로 지정하는 것을 권장합니다.
