#!/usr/bin/python3
# -*- coding: utf-8 -*-
from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)

# Load variables from variables.txt
def load_variables(file_name):
    variables = {}
    with open(file_name, 'r') as file:
        for line in file:
            key, value = line.strip().split('=')
            variables[key] = value
    return variables

# 하나의 app으로 여러채널에 메시지를 보내는 방식으로 변경
SLACK_CHANNEL_LIST_CONFIG=load_variables('variables/channel_list.txt')

# OS 환경변수로 받는것으로 변경
SLACK_TOKEN = os.getenv('SLACK_TOKEN')

SLACK_CHANNEL_DEV = SLACK_CHANNEL_LIST_CONFIG.get('DEV_CHANNEL_ID')  # Channel ID to send messages
SLACK_CHANNEL_INFRA = SLACK_CHANNEL_LIST_CONFIG.get('INFRA_CHANNEL_ID')  # Slack channel for infra
SLACK_CHANNEL_APPLICATION = SLACK_CHANNEL_LIST_CONFIG.get('APPLICATION_CHANNEL_ID')  # Slack channel for smslog

@app.route('/send-message/dev', methods=['POST'])
def send_message_dev():
    data = request.json
    text = data.get('text', 'Hello from Docker!')

    # Slack API call
    response = requests.post('https://slack.com/api/chat.postMessage', json={
        'channel': SLACK_CHANNEL_DEV,
        'text': text
    }, headers={
        'Authorization': f'Bearer {SLACK_TOKEN}',
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
        'Authorization': f'Bearer {SLACK_TOKEN}',
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
        'Authorization': f'Bearer {SLACK_TOKEN}',
        'Content-Type': 'application/json'
    })

    return jsonify(response.json()), response.status_code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
