import configparser
import os
import torch
import numpy as np
from datasets import load_dataset
from transformers import (
    ElectraTokenizer,
    ElectraForSequenceClassification,
    Trainer,
    TrainingArguments,
    DataCollatorWithPadding,
    TrainerCallback
)
from sklearn.metrics import accuracy_score, f1_score

# WANDB 비활성화 (필요 시 주석 해제)
os.environ["WANDB_DISABLED"] = "true"

# ==========================================
# 0. 유틸리티 & 콜백
# ==========================================
def get_data_format(file_path):
    ext = file_path.split('.')[-1].lower()
    if ext == 'csv': return 'csv'
    elif ext in ['json', 'jsonl']: return 'json'
    elif ext == 'parquet': return 'parquet'
    return 'csv'

class DescriptionCallback(TrainerCallback):
    """학습 진행 상황을 직관적으로 보여주는 콜백"""
    def on_log(self, args, state, control, logs=None, **kwargs):
        if state.is_local_process_zero and logs:
            if 'loss' in logs:
                print(f"[Epoch: {logs.get('epoch', 0):.2f}] Loss: {logs['loss']:.4f}")

# ==========================================
# 1. Config 로드
# ==========================================
config = configparser.ConfigParser()
if not os.path.exists('config.ini'):
    raise FileNotFoundError("❌ 'config.ini' 파일이 없습니다.")
config.read('config.ini')

# [Path]
MODEL_NAME_CFG = config['Path']['model_name']
TRAIN_FILE = os.path.abspath(config['Path']['train_file'])
VALID_FILE_RAW = config['Path'].get('valid_file', '').strip()
VALID_FILE = os.path.abspath(VALID_FILE_RAW) if VALID_FILE_RAW else ""
OUTPUT_DIR = config['Path']['output_dir']
CHECKPOINT_DIR = config['Path']['checkpoint_dir']

# [Hyperparameters]
NUM_LABELS = config.getint('Hyperparameters', 'num_labels')
MAX_LEN = config.getint('Hyperparameters', 'max_seq_length')
BATCH_SIZE = config.getint('Hyperparameters', 'batch_size')
LR = config.getfloat('Hyperparameters', 'learning_rate')
EPOCHS = config.getint('Hyperparameters', 'epochs')
SEED = config.getint('Hyperparameters', 'seed')
SPLIT_RATIO = config.getfloat('Hyperparameters', 'split_ratio')
USE_SUBSET = config.getboolean('Hyperparameters', 'use_subset', fallback=False)
SUBSET_SIZE = config.getint('Hyperparameters', 'subset_size', fallback=100)

print(f"▶ Config Loaded")
print(f"   - Train File: {TRAIN_FILE}")
print(f"   - Batch Size: {BATCH_SIZE} (⚠ OOM 주의)")
print(f"   - Learning Rate: {LR}")

# ==========================================
# 2. 데이터셋 로드 및 분할
# ==========================================
data_format = get_data_format(TRAIN_FILE)

if VALID_FILE and os.path.exists(VALID_FILE):
    print(f"▶ 검증 파일 사용: {VALID_FILE}")
    dataset = load_dataset(data_format, data_files={"train": TRAIN_FILE, "validation": VALID_FILE})
    train_dataset = dataset["train"]
    eval_dataset = dataset["validation"]
else:
    print(f"▶ 검증 파일 없음 -> 학습 데이터에서 {SPLIT_RATIO*100}% 자동 분할")
    raw_dataset = load_dataset(data_format, data_files={"train": TRAIN_FILE})
    # 시드 고정하여 분할
    split_datasets = raw_dataset["train"].train_test_split(test_size=SPLIT_RATIO, seed=SEED)
    train_dataset = split_datasets["train"]
    eval_dataset = split_datasets["test"]

# 컬럼명 정규화 (대소문자 무시하고 'label'로 통일)
for col in train_dataset.column_names:
    if col.lower() == 'label' and col != 'label':
        train_dataset = train_dataset.rename_column(col, "label")
        eval_dataset = eval_dataset.rename_column(col, "label")

# Subset 모드 (테스트용)
if USE_SUBSET:
    print(f"⚠ [TEST MODE] 데이터 축소 실행 (Train: {SUBSET_SIZE})")
    train_dataset = train_dataset.select(range(min(len(train_dataset), SUBSET_SIZE)))
    eval_dataset = eval_dataset.select(range(min(len(eval_dataset), int(SUBSET_SIZE * 0.2))))

print(f"✅ 데이터 준비 완료: Train({len(train_dataset)}), Eval({len(eval_dataset)})")

# ==========================================
# 3. 토크나이저 및 모델 로드
# ==========================================
print("⏳ 모델 및 토크나이저 로드 중 ...")

# 모델 경로가 로컬에 없으면 HuggingFace Hub의 기본 모델 사용 (안전장치)
if not os.path.exists(MODEL_NAME_CFG) and "/" not in MODEL_NAME_CFG:
     # 경로도 아니고 Hub ID도 아닌 것 같을 때
     print(f"⚠ 경고: '{MODEL_NAME_CFG}' 경로를 찾을 수 없습니다.")
     
try:
    # KoELECTRA Tokenizer 로드
    tokenizer = ElectraTokenizer.from_pretrained(MODEL_NAME_CFG)
except OSError:
    print(f"⚠ '{MODEL_NAME_CFG}' 로드 실패. 'monologg/koelectra-base-v3-discriminator'로 대체합니다.")
    MODEL_NAME_CFG = "monologg/koelectra-base-v3-discriminator"
    tokenizer = ElectraTokenizer.from_pretrained(MODEL_NAME_CFG)

# 전처리 함수
def preprocess_function(examples):
    # 텍스트 컬럼 찾기
    col_candidates = ["text", "content", "document", "review", "title"] 
    text_col = next((c for c in col_candidates if c in examples), None)
    if not text_col:
        # label이 아닌 첫 번째 컬럼을 텍스트로 간주
        text_col = [c for c in examples.keys() if c != 'label'][0]
        
    return tokenizer(
        examples[text_col], 
        truncation=True, 
        padding="max_length", 
        max_length=MAX_LEN
    )

tokenized_train = train_dataset.map(preprocess_function, batched=True)
tokenized_eval = eval_dataset.map(preprocess_function, batched=True)

# 모델 로드 (Discriminator 명시)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = ElectraForSequenceClassification.from_pretrained(
    MODEL_NAME_CFG, 
    num_labels=NUM_LABELS
)
model.to(device)

# ==========================================
# 4. 학습 설정 (Trainer)
# ==========================================
def compute_metrics(eval_pred):
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    acc = accuracy_score(labels, predictions)
    f1 = f1_score(labels, predictions, average="macro")
    return {"accuracy": acc, "f1": f1}

training_args = TrainingArguments(
    output_dir=CHECKPOINT_DIR,        # 체크포인트 저장소
    learning_rate=LR,
    per_device_train_batch_size=BATCH_SIZE,
    per_device_eval_batch_size=BATCH_SIZE,
    num_train_epochs=EPOCHS,
    weight_decay=0.01,
    eval_strategy="epoch",            # 매 epoch마다 검증
    save_strategy="epoch",            # 매 epoch마다 저장
    load_best_model_at_end=True,      # 학습 종료 시 가장 좋았던 모델 로드
    metric_for_best_model="accuracy", # 정확도 기준
    save_total_limit=2,               # 용량 관리를 위해 최근 2개만 저장
    seed=SEED,
    logging_steps=50,
    warmup_ratio=0.1,                 # KoELECTRA 학습 안정화를 위한 Warmup
    fp16=torch.cuda.is_available(),   # GPU 사용 시 FP16(Mixed Precision) 자동 적용 -> 속도 향상 & 메모리 절약
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_eval,
    data_collator=DataCollatorWithPadding(tokenizer=tokenizer),
    compute_metrics=compute_metrics,
    callbacks=[DescriptionCallback()],
)

# ==========================================
# 5. 학습 실행
# ==========================================
print("🚀 학습 시작 ...")
trainer.train()

# ==========================================
# 6. 최종 모델 저장
# ==========================================
print(f"💾 최종 모델 저장 중 ... ({OUTPUT_DIR})")
model.save_pretrained(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

print("🎉 학습 완료! 이제 추론에 사용할 수 있습니다.")
