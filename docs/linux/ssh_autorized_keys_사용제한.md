# SSH Autorized_keys 파일을 통한 키 사용제한 

## 사용 방법

### root 계정에 대한 키 접근 허용

- .ssh/authorized_keys 파일에서 다음과 같이 설정 

```sh
# 특정IP에서만 키를 통해 접근 가능
from="[접속 허용 IP]" ssh-rsa xxxxx

# 모든 접속에 대한 Root 계정 접근 차단
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"ubuntu\" rather than the user \"root\".';echo;sleep 10" ssh-rsa xxxxx
```

