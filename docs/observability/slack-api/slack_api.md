# Slack API - Docker&python

## 개요 
- Slack에 webhook을 통해 메세지를 전송하는 API를 구성
- Python으로 작성하며, dockerfile을 통해 docker container로 실행


## 구성 방법

1. workspace 및 채널 생성

2. app 생성 
	- https://api.slack.com/
		> Your Apps > Create New App > From manifest 
	- 알림 채널에 등록

3. Incoming Webhooks 활성화 
	- Features > Incoming Webhooks > Activate Incoming Webhooks "ON"
	- Add New Webhook to Workspace > 메세지 개시할 채널 선택 

4. OAuth & Permissions 
	Scopes > Bot Token Scopes or User Token Scopes에 scope 추가 
	- chat:write.public 권한 추가 
	- bot에 추가해서 Token사용하면 APP 이름으로 메세지가 오고 User Token을 쓰면 User명으로 메세지 발송 
	
	- 주요 사용 권한 목록 
	- channels:read : View basic information about public channels in a workspace
	- chat:write : Post messages in approved channels & conversations
	- chat:write.public : Send messages to channels @your_slack_app isn't a member of
	
	* Scope 조정 후에는 App Reinstall 필수

    - 설정 완료 후, 위의 OAuth 토큰 값을 복사하여 사용

5. Slack 채널 ID 확인 
- Slack APP에서 연결한 채널에서 오른쪽 클릭 > 채널 세부정보 보기
    - 아래의 채널 ID를 복사하여 사용

6. Slack API - docker container 생성 

- app.py 
    - 실행 파일

- requirements.txt
    - 필요 pip 모듈 목록

- variables/
	- dev_variables.txt
 	- infra_variables.txt
  	- application_variables.txt
    - Slack 채널 및 토큰 정보 포함


> cat app.py
```py
# -*- coding: utf-8 -*-
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Load variables from variables.txt
def load_variables(file_name):
    variables = {}
    with open(file_name, 'r') as file:
        for line in file:
            key, value = line.strip().split('=')
            variables[key] = value
    return variables

dev_config = load_variables('variables/dev_variables.txt')
infra_config = load_variables('variables/infra_variables.txt')
application_config = load_variables('variables/application_variables.txt')

SLACK_TOKEN_DEV = dev_config.get('SLACK_TOKEN')  # Slack OAuth token
SLACK_CHANNEL_DEV = dev_config.get('SLACK_CHANNEL')  # Channel ID to send messages

SLACK_TOKEN_INFRA = infra_config.get('SLACK_TOKEN')  # Slack OAuth token for infra
SLACK_CHANNEL_INFRA = infra_config.get('SLACK_CHANNEL')  # Slack channel for infra

SLACK_TOKEN_APPLICATION = application_config.get('SLACK_TOKEN')  # Slack OAuth token for smslog
SLACK_CHANNEL_APPLICATION = application_config.get('SLACK_CHANNEL')  # Slack channel for smslog

@app.route('/send-message/dev', methods=['POST'])
def send_message_dev():
    data = request.json
    text = data.get('text', 'Hello from Docker!')

    # Slack API call
    response = requests.post('https://slack.com/api/chat.postMessage', json={
        'channel': SLACK_CHANNEL_DEV,
        'text': text
    }, headers={
        'Authorization': f'Bearer {SLACK_TOKEN_DEV}',
        'Content-Type': 'application/json'
    })

    return jsonify(response.json()), response.status_code


@app.route('/send-message/infra', methods=['POST'])
def send_message_infra():
    data = request.json
    text = data.get('text', 'Hello from Infra!')

    # Slack API call for infra
    response = requests.post('https://slack.com/api/chat.postMessage', json={
        'channel': SLACK_CHANNEL_INFRA,
        'text': text
    }, headers={
        'Authorization': f'Bearer {SLACK_TOKEN_INFRA}',
        'Content-Type': 'application/json'
    })

    return jsonify(response.json()), response.status_code


@app.route('/send-message/application', methods=['POST'])
def send_message_application():
    data = request.json
    text = data.get('text', 'Hello from Web!')

    # Slack API call for smslog
    response = requests.post('https://slack.com/api/chat.postMessage', json={
        'channel': SLACK_CHANNEL_APPLICATION,
        'text': text
    }, headers={
        'Authorization': f'Bearer {SLACK_TOKEN_APPLICATION}',
        'Content-Type': 'application/json'
    })

    return jsonify(response.json()), response.status_code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```	
> cat requirements.txt
```
Flask
requests
```

> cat variables/dev_variables.txt
```
SLACK_TOKEN=[SLACK_OAuth_Token]
SLACK_CHANNEL=[SLACK_CHANNAL_ID]
```


> dockerfile 
```docker
# Python 3.9 기반 이미지 사용
FROM python:3.9-slim

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY app.py .
RUN mkdir -p /app/variables
COPY variables/* /app/variables/

# 컨테이너 시작 시 Flask 앱 실행
CMD ["python", "app.py"]
```

- docker image build 
```bash
docker build -t slack-api-app .
```

- Docker 컨테이너 실행

```bash
docker run -d -p 5000:5000 --name slack-api slack-api-app
```

7. Slack 메세지 발송 테스트 
```sh
$ curl -X POST http://localhost:5000/send-message/dev -H "Content-Type: application/json" -d '{"text": "slack_test" }'


{"channel":"C075QKNQZJN","message":{"app_id":"A075QGZPSUB","blocks":[{"block_id":"Uheg","elements":[{"elements":[{"text":"Hello, Slack!","type":"text"}],"type":"rich_text_section"}],"type":"rich_text"}],"bot_id":"B07Q9PEJZB2","bot_profile":{"app_id":"A075QGZPSUB","deleted":false,"icons":{"image_36":"https://a.slack-edge.com/80588/img/plugins/app/bot_36.png","image_48":"https://a.slack-edge.com/80588/img/plugins/app/bot_48.png","image_72":"https://a.slack-edge.com/80588/img/plugins/app/service_72.png"},"id":"B07Q9PEJZB2","name":"test-app","team_id":"T07639T5HFB","updated":1727680976},"team":"T07639T5HFB","text":"Hello, Slack!","ts":"1727681075.195169","type":"message","user":"U076DDF2PHN"},"ok":true,"response_metadata":{"warnings":["missing_charset"]},"ts":"1727681075.195169","warning":"missing_charset"}
```
- 정상 작동 확인

8. Slack 메세지 발송 스크립트 작성


> cat send_messages.sh

```bash
#!/bin/bash
host=$(hostname)
ip=$(hostname -i | awk '{print $1}')
messages=$1
slack_api_url="http://localhost:5000/send-message/dev"

curl -X POST $slack_api_url -H "Content-Type: application/json" -d "{\"text\": \"${host}(${ip}) - ${message}\"}"
```



 > cat send_messages.py
 ```py
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
#    print(f"Status Code: {response.status_code}")
    print("Status Code: %s" % response.status_code)
#    print(f"Response Body: {response.text}")
    print("Response Body: %s" % response.text)

if __name__ == "__main__":
    # 명령줄 인수로부터 메시지를 받음
        send_message(message) 
 ```
