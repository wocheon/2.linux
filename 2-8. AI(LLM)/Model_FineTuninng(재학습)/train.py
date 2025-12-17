import configparser
import os
import torch
import numpy as np
from datasets import load_dataset
from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    Trainer,
    TrainingArguments,
    DataCollatorWithPadding
)
from sklearn.metrics import accuracy_score, f1_score

# ==========================================
# 1. Config 로드
# ==========================================
config = configparser.ConfigParser()
if not os.path.exists('config.ini'):
    raise FileNotFoundError("❌ 'config.ini' 파일이 없습니다. 설정을 확인해주세요.")
config.read('config.ini')

# [Path] 섹션
MODEL_NAME = config['Path']['model_name']
TRAIN_FILE = os.path.abspath(config['Path']['train_file']) # 절대 경로로 변환
VALID_FILE_RAW = config['Path'].get('valid_file', '').strip()
VALID_FILE = os.path.abspath(VALID_FILE_RAW) if VALID_FILE_RAW else ""
OUTPUT_DIR = config['Path']['output_dir']
CHECKPOINT_DIR = config['Path']['checkpoint_dir']

# [Hyperparameters] 섹션
NUM_LABELS = config.getint('Hyperparameters', 'num_labels')
MAX_LEN = config.getint('Hyperparameters', 'max_seq_length')
BATCH_SIZE = config.getint('Hyperparameters', 'batch_size')
LR = config.getfloat('Hyperparameters', 'learning_rate')
EPOCHS = config.getint('Hyperparameters', 'epochs')
SEED = config.getint('Hyperparameters', 'seed')
SPLIT_RATIO = config.getfloat('Hyperparameters', 'split_ratio')

# [Subset] 테스트용 옵션 (config.ini에 없으면 기본값 False 사용)
USE_SUBSET = config.getboolean('Hyperparameters', 'use_subset', fallback=False)
SUBSET_SIZE = config.getint('Hyperparameters', 'subset_size', fallback=100)

print(f"▶ 모델: {MODEL_NAME}")
print(f"▶ 학습 파일: {TRAIN_FILE}")

# ==========================================
# 2. 데이터셋 로드 및 분할
# ==========================================
# 1) Validation 파일 유무에 따른 로드
if VALID_FILE and os.path.exists(VALID_FILE):
    print(f"▶ 검증 파일: {VALID_FILE}")
    dataset = load_dataset("parquet", data_files={"train": TRAIN_FILE, "validation": VALID_FILE})
    train_dataset = dataset["train"]
    eval_dataset = dataset["validation"]
else:
    print(f"▶ 검증 파일: 없음 (학습 데이터에서 {SPLIT_RATIO*100}% 자동 분할)")
    raw_dataset = load_dataset("parquet", data_files={"train": TRAIN_FILE})
    # 시드 고정하여 분할
    split_datasets = raw_dataset["train"].train_test_split(test_size=SPLIT_RATIO, seed=SEED)
    train_dataset = split_datasets["train"]
    eval_dataset = split_datasets["test"]

print(f"✅ 데이터 로드 완료: 학습({len(train_dataset)}) / 검증({len(eval_dataset)})")

# 2) 컬럼명 변경 (Label -> label, Text -> Review_Text 확인 필요)
# 실제 데이터셋의 컬럼명을 확인 후 필요하면 수정
print(f"▶ 데이터셋 컬럼 목록: {train_dataset.column_names}")

if "Label" in train_dataset.column_names:
    train_dataset = train_dataset.rename_column("Label", "label")
    eval_dataset = eval_dataset.rename_column("Label", "label")
    print("  -> 컬럼명 변경 완료: Label -> label")

# 3) 데이터셋 축소 (테스트 모드일 때만 동작)
if USE_SUBSET:
    print(f"\n⚠ [테스트 모드] 데이터셋 축소 (학습: {SUBSET_SIZE}개 기준)")
    
    # 학습 데이터 축소
    if len(train_dataset) > SUBSET_SIZE:
        train_dataset = train_dataset.select(range(SUBSET_SIZE))
    
    # 검증 데이터도 비율에 맞춰 축소 (학습 데이터의 20% 크기)
    eval_subset_size = max(int(SUBSET_SIZE * 0.2), 10) # 최소 10개는 보장
    if len(eval_dataset) > eval_subset_size:
        eval_dataset = eval_dataset.select(range(eval_subset_size))
        
    print(f"▶ 축소된 데이터 개수: 학습({len(train_dataset)}) / 검증({len(eval_dataset)})\n")

# ==========================================
# 3. 전처리 (Tokenizer)
# ==========================================
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

def preprocess_function(examples):
    # 주의: 데이터셋의 실제 텍스트 컬럼명이 'Review_Text'인지 'text'인지 확인 필요!
    # 여기서는 질문자님의 데이터에 맞춰 'Review_Text'로 설정함
    return tokenizer(
        examples["Review_Text"], 
        truncation=True, 
        padding="max_length", 
        max_length=MAX_LEN
    )

print("⏳ 데이터 토크나이징 중...")
tokenized_train = train_dataset.map(preprocess_function, batched=True)
tokenized_eval = eval_dataset.map(preprocess_function, batched=True)

# ==========================================
# 4. 모델 및 학습 실행
# ==========================================
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME, num_labels=NUM_LABELS)

def compute_metrics(eval_pred):
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    acc = accuracy_score(labels, predictions)
    f1 = f1_score(labels, predictions, average="macro")
    return {"accuracy": acc, "f1": f1}

training_args = TrainingArguments(
    output_dir=CHECKPOINT_DIR,
    learning_rate=LR,
    per_device_train_batch_size=BATCH_SIZE,
    per_device_eval_batch_size=BATCH_SIZE,
    num_train_epochs=EPOCHS,
    weight_decay=0.01,
    eval_strategy="epoch",  # 최신 버전 호환 (evaluation_strategy -> eval_strategy)
    save_strategy="epoch",
    load_best_model_at_end=True,
    save_total_limit=2,
    seed=SEED,
    dataloader_pin_memory=False, # CPU 환경 등에서 경고 방지
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_eval,
    processing_class=tokenizer, # tokenizer -> processing_class (최신 경고 대응)
    data_collator=DataCollatorWithPadding(tokenizer=tokenizer),
    compute_metrics=compute_metrics,
)

print("🚀 학습 시작...")
trainer.train()

# ==========================================
# 5. 최종 저장
# ==========================================
print(f"💾 최종 모델 저장 중... ({OUTPUT_DIR})")
trainer.save_model(OUTPUT_DIR)
print("🎉 완료!")

