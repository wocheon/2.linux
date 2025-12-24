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
    DataCollatorWithPadding,
    TrainerCallback
)
from sklearn.metrics import accuracy_score, f1_score

# ==========================================
# 0. 유틸리티 & 콜백 클래스
# ==========================================
def get_data_format(file_path):
    """파일 확장자를 기반으로 load_dataset의 포맷 파라미터를 결정"""
    ext = file_path.split('.')[-1].lower()
    if ext == 'csv': return 'csv'
    elif ext in ['json', 'jsonl']: return 'json'
    elif ext == 'parquet': return 'parquet'
    else:
        print(f"⚠ 알 수 없는 확장자(.{ext})입니다. 기본값 'csv'로 시도합니다.")
        return 'csv'

class DescriptionCallback(TrainerCallback):
    """학습 로그를 더 친절하게 출력하는 커스텀 콜백"""
    def on_log(self, args, state, control, logs=None, **kwargs):
        if state.is_local_process_zero and logs:
            epoch_info = f"[Epoch: {logs.get('epoch', 0):.2f}]"
            if 'loss' in logs:
                loss_val = logs['loss']
                if loss_val > 0.8: comment = "😰 아직 헤매는 중..."
                elif loss_val > 0.5: comment = "🤔 감을 잡는 중..."
                elif loss_val > 0.3: comment = "🙂 학습이 잘 되고 있어요!"
                else: comment = "🚀 완벽해요!"
                print(f"{epoch_info} Loss: {loss_val:.4f} -> {comment}")
            if 'learning_rate' in logs:
                print(f"   └─ LR: {logs['learning_rate']:.2e}")

# ==========================================
# 1. Config 로드
# ==========================================
config = configparser.ConfigParser()
if not os.path.exists('config.ini'):
    raise FileNotFoundError("❌ 'config.ini' 파일이 없습니다. 설정을 확인해주세요.")
config.read('config.ini')

# [Path]
MODEL_NAME = config['Path']['model_name']
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

# [Subset]
USE_SUBSET = config.getboolean('Hyperparameters', 'use_subset', fallback=False)
SUBSET_SIZE = config.getint('Hyperparameters', 'subset_size', fallback=100)

print(f"▶ 모델: {MODEL_NAME}")
print(f"▶ 학습 파일: {TRAIN_FILE}")

# ==========================================
# 2. 데이터셋 로드
# ==========================================
data_format = get_data_format(TRAIN_FILE)
print(f"▶ 감지된 포맷: {data_format}")

if VALID_FILE and os.path.exists(VALID_FILE):
    print(f"▶ 검증 파일: {VALID_FILE}")
    dataset = load_dataset(data_format, data_files={"train": TRAIN_FILE, "validation": VALID_FILE})
    train_dataset = dataset["train"]
    eval_dataset = dataset["validation"]
else:
    print(f"▶ 검증 파일 없음 (학습 데이터에서 {SPLIT_RATIO*100}% 자동 분할)")
    raw_dataset = load_dataset(data_format, data_files={"train": TRAIN_FILE})
    if len(raw_dataset["train"]) < 10:
        raise ValueError("❌ 데이터가 너무 적습니다. 최소 10개 이상 필요합니다.")
    split_datasets = raw_dataset["train"].train_test_split(test_size=SPLIT_RATIO, seed=SEED)
    train_dataset = split_datasets["train"]
    eval_dataset = split_datasets["test"]

# 컬럼명 통일 (Label, LABEL -> label)
for col in train_dataset.column_names:
    if col.lower() == 'label' and col != 'label':
        train_dataset = train_dataset.rename_column(col, "label")
        eval_dataset = eval_dataset.rename_column(col, "label")

if USE_SUBSET:
    print(f"\n⚠ [테스트 모드] 데이터 축소 실행")
    if len(train_dataset) > SUBSET_SIZE:
        train_dataset = train_dataset.select(range(SUBSET_SIZE))
    eval_dataset = eval_dataset.select(range(min(len(eval_dataset), int(SUBSET_SIZE * 0.2))))

print(f"✅ 데이터 준비 완료: 학습({len(train_dataset)}) / 검증({len(eval_dataset)})")

# ==========================================
# 3. 토크나이저 로드 및 패치 (중요!)
# ==========================================
print("⏳ 토크나이저 로드 중...")
try:
    # trust_remote_code=True 추가로 보안 경고 자동 승인
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME, trust_remote_code=True)
except Exception as e:
    print(f"⚠ 토크나이저 로드 실패. SentencePiece 문제일 수 있습니다.\n에러: {e}")
    raise e

# [Monkey Patch] save_vocabulary 호환성 문제 해결
# KoBERT 구버전 토크나이저가 filename_prefix 인자를 못 받아서 터지는 문제 해결
if not hasattr(tokenizer, "_original_save_vocabulary"):
    # 원래 메서드가 있다면 백업해두고 (없으면 패스)
    if hasattr(tokenizer, "save_vocabulary"):
        tokenizer._original_save_vocabulary = tokenizer.save_vocabulary

def patched_save_vocabulary(save_directory, filename_prefix=None):
    # filename_prefix 인자가 들어와도 무시하고, 원래 저장 로직 실행
    if hasattr(tokenizer, "_original_save_vocabulary"):
        return tokenizer._original_save_vocabulary(save_directory)
    else:
        # 원래 메서드도 없으면 그냥 빈 튜플 반환 (에러 방지)
        return ()

# 메서드 덮어쓰기
tokenizer.save_vocabulary = patched_save_vocabulary
print("🔧 토크나이저 호환성 패치 적용 완료")

# 전처리 함수
def preprocess_function(examples):
    col_candidates = ["text", "Text", "review", "content", "document", "Review_Text"]
    text_col = next((c for c in col_candidates if c in examples), None)
    if not text_col:
        text_col = [c for c in examples.keys() if c != 'label'][0]
        
    return tokenizer(
        examples[text_col], 
        truncation=True, 
        padding="max_length", 
        max_length=MAX_LEN
    )

tokenized_train = train_dataset.map(preprocess_function, batched=True)
tokenized_eval = eval_dataset.map(preprocess_function, batched=True)

# ==========================================
# 4. 모델 및 학습 설정
# ==========================================
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"▶ 학습 장치: {device}")

# trust_remote_code=True 추가로 보안 경고 자동 승인
model = AutoModelForSequenceClassification.from_pretrained(
    MODEL_NAME, 
    num_labels=NUM_LABELS,
    trust_remote_code=True
)
model.to(device)

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
    eval_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True,
    save_total_limit=2,
    seed=SEED,
    logging_dir=f"{OUTPUT_DIR}/logs",
    logging_steps=10,
    disable_tqdm=False,
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
# 5. 학습 실행 및 안전 저장
# ==========================================
print("🚀 학습 시작...")

try:
    trainer.train()
except TypeError as e:
    # filename_prefix 에러 등은 무시하고 저장 단계로 진행
    if "filename_prefix" in str(e) or "save_vocabulary" in str(e):
        print("⚠ Trainer 자동 저장 중 호환성 이슈 발생 (무시하고 수동 저장 진행)")
    else:
        # 진짜 심각한 에러는 다시 발생시킴
        print(f"❌ 학습 중 치명적 에러 발생: {e}")
        # 그래도 모델은 살려본다
        model.save_pretrained(f"{OUTPUT_DIR}_emergency")
        raise e
except Exception as e:
    print(f"❌ 예상치 못한 에러: {e}")
    model.save_pretrained(f"{OUTPUT_DIR}_emergency")
    raise e

print(f"💾 최종 모델 저장 중... ({OUTPUT_DIR})")
# 모델 저장
model.save_pretrained(OUTPUT_DIR)

# 토크나이저 저장 (에러 발생 시 건너뜀)
try:
    tokenizer.save_pretrained(OUTPUT_DIR)
except Exception as e:
    print(f"⚠ 토크나이저 저장 실패 (모델은 저장됨): {e}")

print("🎉 모든 작업이 완료되었습니다! (app.py에서 사용 가능)")

