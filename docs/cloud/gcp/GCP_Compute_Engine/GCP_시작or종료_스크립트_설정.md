# GCP 시작/종료 스크립트 설정

Ubuntu 24.04 LTS VM 기준의 Slack 알림 테스트 예제입니다. Rocky Linux 9에도 동일한 Bash 스크립트를 적용할 수 있습니다. 시작·종료 스크립트는 root로 실행되므로 Webhook URL을 VM 메타데이터나 Git 저장소에 직접 넣지 않습니다.

## 준비
Slack Incoming Webhook URL을 VM 안의 `/etc/default/vm-slack-notify`에 관리자가 직접 저장하고 `sudo chmod 600 /etc/default/vm-slack-notify`로 보호합니다. 예: `SLACK_WEBHOOK_URL=https://hooks.slack.com/services/REPLACE/ME`. VM에 `curl`이 필요합니다.

## 시작 스크립트 (`startup-script` 메타데이터)
```bash
#!/usr/bin/env bash
set -u
[ -r /etc/default/vm-slack-notify ] || exit 0
. /etc/default/vm-slack-notify
[ -n "${SLACK_WEBHOOK_URL:-}" ] || exit 0
HOSTNAME=$(hostname)
curl --silent --show-error --fail --max-time 5 --retry 2 \
  -H 'Content-type: application/json' \
  --data "{\"text\":\"GCE ${HOSTNAME}: 시작됨\"}" \
  "$SLACK_WEBHOOK_URL"
```

## 종료 스크립트 (`shutdown-script` 메타데이터)
```bash
#!/usr/bin/env bash
set -u
[ -r /etc/default/vm-slack-notify ] || exit 0
. /etc/default/vm-slack-notify
[ -n "${SLACK_WEBHOOK_URL:-}" ] || exit 0
HOSTNAME=$(hostname)
curl --silent --show-error --fail --max-time 3 \
  -H 'Content-type: application/json' \
  --data "{\"text\":\"GCE ${HOSTNAME}: 종료 중\"}" \
  "$SLACK_WEBHOOK_URL"
```

VM 메타데이터의 `startup-script`/`shutdown-script`에 각각 붙여 넣거나 파일을 지정합니다. 종료 시 네트워크가 이미 끊겼거나 제한 시간이 초과되면 알림은 전달되지 않을 수 있습니다. 비밀정보 배포에는 Secret Manager 등 별도 방식을 사용합니다.

참고: [Linux 시작 스크립트](https://cloud.google.com/compute/docs/instances/startup-scripts/linux), [Linux 종료 스크립트](https://cloud.google.com/compute/docs/shutdownscript)
