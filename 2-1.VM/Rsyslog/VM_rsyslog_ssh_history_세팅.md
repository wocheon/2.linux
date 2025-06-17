# VM rsyslog Setting (CentOS7)

## 개요
- ssh 접속자가 실행한 커맨드 기록을 rsyslog를 통해 로그파일에 기록

## rsyslog 세팅 
- /var/log/prompt.log 파일에 명령어 실행 기록 저장

>vi /etc/rsyslog.conf
```sh
#해당 라인 추가
local3.* /var/log/prompt.log
```

## profile 세팅 
- 모든 접속자에 적용을 위해 /etc/profile 파일에 환경변수 세팅
> vi /etc/profile 
```sh
whoami="$(whoami)@$(echo $SSH_CONNECTION | awk '{print $1}')"
export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local3.debug "$whoami [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//") [$RETRN_VAL]"'
HISTSIZE=20000
export HISTTIMEFORMAT="%Y-%m-%d_%H:%M:%s\ "
```

### 변경 사항 적용 후 기록 내용 확인
- 로그아웃 혹은 /etc/profile 파일 재적용
```
source /etc/profile
```

- rsyslog 재시작
```
systemctl restart rsyslog 
```

- 로그파일 확인 
```sh
Jul  9 16:57:41 gcp-ansible-test root: root@165.243.5.20 [1477]: [2024-07-09_16:57:41]  source /etc/profile [0]
Jul  9 16:57:44 gcp-ansible-test root: root@165.243.5.20 [1477]: [2024-07-09_16:57:44]  systemctl restart rsyslog [0]
Jul  9 16:57:45 gcp-ansible-test root: root@165.243.5.20 [1477]: [2024-07-09_16:57:45]  ll [0]
Jul  9 16:57:54 gcp-ansible-test root: root@165.243.5.20 [1477]: [2024-07-09_16:57:54]  cat /etc/profile [0]
Jul 10 09:19:34 gcp-ansible-test root: root@165.243.5.20 [1291]: [2024-07-10_09:16:26]  vim /etc/profile [0]
Jul 10 09:21:05 gcp-ansible-test root: root@165.243.5.20 [1291]: [2024-07-10_09:19:41]  vim /etc/rsyslog.conf  [0]
```
