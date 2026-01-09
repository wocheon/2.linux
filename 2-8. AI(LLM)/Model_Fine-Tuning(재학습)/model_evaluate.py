import os
import glob
import numpy as np
import evaluate
from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer, TrainingArguments

# ==========================================================
# 1. 설정 (경로 및 컬럼명 확인 필수)
# ==========================================================
# WandB 끄기 (에러 방지)
os.environ["WANDB_DISABLED"] = "true"

# 모델 경로
MODEL_PATH = "./models/fine_tunned_koelectra"

# 데이터 파일들이 있는 폴더 경로 (마지막에 슬래시 없어도 됨)
DATA_DIR = "./dataset_dir"

# CSV 내 컬럼 이름 (실제 파일과 일치해야 함!)
TEXT_COLUMN = "text"
LABEL_COLUMN = "label"

# ==========================================================
# 2. 모델 및 토크나이저 로드
# ==========================================================
print(f"⏳ 모델 로드 중: {MODEL_PATH}")
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH, trust_remote_code=True)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)

# ==========================================================
# 3. 데이터 로드 (여러 CSV 합치기)
# ==========================================================
# 폴더 내 모든 .csv 파일 찾기
csv_files = glob.glob(os.path.join(DATA_DIR, "*.csv"))

if not csv_files:
    raise FileNotFoundError(f"❌ '{DATA_DIR}' 경로에 .csv 파일이 하나도 없습니다!")

print(f"📂 발견된 데이터 파일 ({len(csv_files)}개):")
for f in csv_files:
    print(f" - {f}")

# 여러 파일을 한 번에 로드 (자동으로 합쳐짐)
# split="train"을 지정해야 DatasetDict가 아닌 Dataset 객체가 나옴
combined_dataset = load_dataset("csv", data_files=csv_files, split="train")

print(f"✅ 총 데이터 개수: {len(combined_dataset)}")

# 전처리 함수
def preprocess_function(examples):
    # None이나 비문자열 데이터 방어 코드
    texts = [str(x) if x is not None else "" for x in examples[TEXT_COLUMN]]
    return tokenizer(
        texts,
        truncation=True,
        max_length=128,
        padding="max_length"
    )

print("⚙️ 데이터 전처리(토큰화) 중...")
tokenized_dataset = combined_dataset.map(preprocess_function, batched=True)

# 여기서는 '전체 데이터를 평가용'으로 쓴다고 가정 (이미 학습이 끝난 모델이므로)
# 만약 여기서도 일부만 뽑고 싶다면 .select() 등을 사용
test_dataset = tokenized_dataset

print(f"✅ 최종 평가 데이터 준비 완료: {len(test_dataset)}개")

# ==========================================================
# 4. 평가 지표 정의
# ==========================================================
accuracy_metric = evaluate.load("accuracy")
f1_metric = evaluate.load("f1")

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)

    accuracy = accuracy_metric.compute(predictions=predictions, references=labels)
    # average="macro": 클래스별 성능 평균 (불균형 데이터에 좋음)
    f1 = f1_metric.compute(predictions=predictions, references=labels, average="macro")

    return {
        "accuracy": accuracy["accuracy"],
        "f1": f1["f1"]
    }

# ==========================================================
# 5. 평가 실행
# ==========================================================
training_args = TrainingArguments(
    output_dir="./temp_eval_results",
    report_to="none",
    per_device_eval_batch_size=64  # 속도를 위해 배치 크게
)

trainer = Trainer(
    model=model,
    args=training_args,
    eval_dataset=test_dataset,
    tokenizer=tokenizer,
    compute_metrics=compute_metrics
)

print("🚀 평가 시작...")
metrics = trainer.evaluate()

print("\n📊 최종 평가 성적표:")
print("=" * 30)
for key, value in metrics.items():
    print(f"{key}: {value:.4f}")
print("=" * 30)