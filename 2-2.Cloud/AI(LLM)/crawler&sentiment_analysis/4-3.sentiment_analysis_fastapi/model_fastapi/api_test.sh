#!/bin/bash

text_msg="I am sorry to hear that"

echo "* Test Message : $text_msg"
echo "* Answer"
curl -X POST "http://localhost:8000/predict/koelectra" -H "Content-Type: application/json" -d "{\"text\":\"$text_msg\"}"
echo ""
