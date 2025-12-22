#!/bin/bash


echo "* Test kobert Batch Request"
echo "* Sending 3 sentences..."

curl -X POST "http://localhost:8000/predict/kobert/batch" \
  -H "Content-Type: application/json" \
  -d '{
    "texts": [
      "I am sorry to hear that",
      "Wow, this is amazing!",
      "I am so angry right now"
    ]
  }'

echo ""
echo "* Test koelectra Batch Request"
echo "* Sending 3 sentences..."

curl -X POST "http://localhost:8000/predict/koelectra/batch" \
  -H "Content-Type: application/json" \
  -d '{
    "texts": [
      "I am sorry to hear that",
      "Wow, this is amazing!",
      "I am so angry right now"
    ]
  }'

echo ""
echo "* Test LLM Batch Request"
echo "* Sending 3 sentences..."

curl -X POST "http://localhost:8000/predict/llm/batch" \
  -H "Content-Type: application/json" \
  -d '{
    "texts": [
      "I am sorry to hear that",
      "Wow, this is amazing!",
      "I am so angry right now"
    ]
  }'

echo ""
echo "* Done"
