# -*- coding: utf-8 -*-
import requests
import json
import sys

message = sys.argv[1]  # 첫 번째 인수로 메시지 내용

def send_message(message):
    # POST 요청을 보낼 URL
    url = "http://localhost:5000/send-message/dev"
    
    # 헤더 설정
    headers = {
        "Content-Type": "application/json"
    }
    
    # 메시지 데이터를 JSON 형식으로 설정
    data = {
        "text": message
    }    
    # POST 요청 보내기
    response = requests.post(url, headers=headers, data=json.dumps(data))
    
    # 응답 출력
    print("Status Code: %s" % response.status_code)
    print("Response Body: %s" % response.text)

if __name__ == "__main__":
    # 명령줄 인수로부터 메시지를 받음
        send_message(message)
