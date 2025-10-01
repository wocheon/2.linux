import os
from dotenv import load_dotenv
from flask import Flask, render_template, request, Response
import openai
from openai.error import OpenAIError
import logging
from logging.handlers import RotatingFileHandler

load_dotenv()

app = Flask(__name__)

# 로그 디렉토리와 파일 설정
log_dir = 'log'
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

log_file = os.path.join(log_dir, 'app.log')
handler = RotatingFileHandler(log_file, maxBytes=10000, backupCount=1)
handler.setLevel(logging.INFO)
formatter = logging.Formatter(
    '%(asctime)s - %(levelname)s - %(message)s'
)
handler.setFormatter(formatter)

# Flask의 기본 로거에 핸들러 추가
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)

# OpenAI API 키 설정
openai.api_key=os.getenv('OPENAI_API_KEY')

# model_type 설정
model_type = 'gpt-4o'  # GPT-4o 모델로 설정

@app.before_request
def log_request_info():
    app.logger.info(
        f"Request: {request.remote_addr} - - [{request.method} {request.path}] "
        f"Headers: {dict(request.headers)} Body: {request.get_data()}"
    )

@app.after_request
def log_response_info(response):
    app.logger.info(
        f"Response: {request.remote_addr} - - [{request.method} {request.path}] "
        f"HTTP/1.1 {response.status_code} - {response.status}"
    )
    return response

@app.route('/')
def index():
    return render_template('index.html')


def generate(messages, model_type):
    def stream():
        try:
            response = openai.ChatCompletion.create(
                model=model_type,
                messages=messages,
                stream=True
            )

            for chunk in response:
                content = chunk['choices'][0]['delta'].get('content', '')
                if content:
                    yield content

        except OpenAIError as e:
            yield f"An error occurred: {str(e)}"

    return stream()


@app.route('/gpt4', methods=['POST'])
def gpt4():
    data = request.get_json()
    messages = data.get('messages', [])

    assistant_response = generate(messages, model_type)
    return Response(assistant_response, mimetype='text/event-stream')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

