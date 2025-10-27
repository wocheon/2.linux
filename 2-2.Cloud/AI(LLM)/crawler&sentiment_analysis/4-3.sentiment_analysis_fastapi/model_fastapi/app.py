from fastapi import FastAPI
from pydantic import BaseModel
import torch
from transformers import AutoTokenizer, BertForSequenceClassification, ElectraForSequenceClassification

# KoBERT용 레이블 매핑
KOBERT_LABEL_MAP = {
    0: "Angry",
    1: "Fear",
    2: "Happy",
    3: "Tender",
    4: "Sad"
}

# KoELECTRA용 레이블 매핑 (예시 - 실제 학습시 다를 수 있음)
KOELECTRA_LABEL_MAP = {
    0: "angry",
    1: "happy",
    2: "anxious",
    3: "embarrassed",
    4: "sad",
    5: "heartache"
}

KOBERT_MODEL_DIR = "/models/kobert"
KOELECTRA_MODEL_DIR = "/models/koelectra"

kobert_tokenizer = AutoTokenizer.from_pretrained(KOBERT_MODEL_DIR)
kobert_model = BertForSequenceClassification.from_pretrained(KOBERT_MODEL_DIR)
kobert_model.eval()

koelectra_tokenizer = AutoTokenizer.from_pretrained(KOELECTRA_MODEL_DIR)
koelectra_model = ElectraForSequenceClassification.from_pretrained(KOELECTRA_MODEL_DIR)
koelectra_model.eval()

app = FastAPI()

class InputText(BaseModel):
    text: str

def predict_sentiment(tokenizer, model, label_map, text):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=256, padding=True)
    with torch.no_grad():
        outputs = model(**inputs)
        prob = torch.softmax(outputs.logits, dim=1)
        pred_label = torch.argmax(prob, dim=1).item()
        score = float(prob[0][pred_label])
    sentiment = label_map.get(pred_label, str(pred_label))
    return sentiment, score

@app.post("/predict/kobert")
async def predict_kobert(request: InputText):
    sentiment, score = predict_sentiment(kobert_tokenizer, kobert_model, KOBERT_LABEL_MAP, request.text)
    return {"model": "kobert", "sentiment": sentiment, "score": score}

@app.post("/predict/koelectra")
async def predict_koelectra(request: InputText):
    sentiment, score = predict_sentiment(koelectra_tokenizer, koelectra_model, KOELECTRA_LABEL_MAP, request.text)
    return {"model": "koelectra", "sentiment": sentiment, "score": score}

