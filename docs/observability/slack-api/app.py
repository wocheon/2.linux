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

config = load_variables('infra_variables.txt')
infra_config = load_variables('infra_variables.txt')
smslog_config = load_variables('smslog_variables.txt')

SLACK_TOKEN = config.get('SLACK_TOKEN')  # Slack OAuth token
SLACK_CHANNEL = config.get('SLACK_CHANNEL')  # Channel ID to send messages

SLACK_TOKEN_INFRA = infra_config.get('SLACK_TOKEN')  # Slack OAuth token for infra
SLACK_CHANNEL_INFRA = infra_config.get('SLACK_CHANNEL')  # Slack channel for infra

SLACK_TOKEN_SMSLOG = smslog_config.get('SLACK_TOKEN')  # Slack OAuth token for smslog
SLACK_CHANNEL_SMSLOG = smslog_config.get('SLACK_CHANNEL')  # Slack channel for smslog

@app.route('/send-message', methods=['POST'])
def send_message():
    data = request.json
    text = data.get('text', 'Hello from Docker!')

    # Slack API call
    response = requests.post('https://slack.com/api/chat.postMessage', json={
        'channel': SLACK_CHANNEL,
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
        'Authorization': f'Bearer {SLACK_TOKEN_INFRA}',
        'Content-Type': 'application/json'
    })

    return jsonify(response.json()), response.status_code


@app.route('/send-message/smslog', methods=['POST'])
def send_message_smslog():
    data = request.json
    text = data.get('text', 'Hello from Web!')

    # Slack API call for smslog
    response = requests.post('https://slack.com/api/chat.postMessage', json={
        'channel': SLACK_CHANNEL_SMSLOG,
        'text': text
    }, headers={
        'Authorization': f'Bearer {SLACK_TOKEN_SMSLOG}',
        'Content-Type': 'application/json'
    })

    return jsonify(response.json()), response.status_code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
