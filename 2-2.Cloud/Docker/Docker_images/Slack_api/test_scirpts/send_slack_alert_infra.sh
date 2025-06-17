#!/bin/bash
host=$(hostname)
ip=$(hostname -i | awk '{print $1}')
messages=$1
slack_api_url="http://localhost:5000/send-message/infra"

curl -X POST $slack_api_url -H "Content-Type: application/json" -d "{\"text\": \"${host}(${ip}) - ${messages}\"}"
