from fastapi import FastAPI
from pydantic import BaseModel
import torch
from transformers import AutoTokenizer, BertForSequenceClassification

LABEL_MAP = {
    0: "Angry",
    1: "Fear",
    2: "Happy",
    3: "Tender",
    4: "Sad"
}

# 모델과 토크나이저를 서버 시작 시 한번 로드
KOBERT_MODEL_DIR = "/models/kobert"
tokenizer = AutoTokenizer.from_pretrained(KOBERT_MODEL_DIR)
model = BertForSequenceClassification.from_pretrained(KOBERT_MODEL_DIR)
model.eval()

app = FastAPI()

class InputText(BaseModel):
    text: str

@app.post("/predict")
async def predict(request: InputText):
    inputs = tokenizer(request.text, return_tensors="pt", truncation=True, max_length=256, padding=True)
    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        prob = torch.softmax(logits, dim=1)
        pred_label = torch.argmax(prob, dim=1).item()
        score = float(prob[0][pred_label])
        sentiment = LABEL_MAP.get(pred_label, str(pred_label))
    return {"sentiment": sentiment, "score": score}

