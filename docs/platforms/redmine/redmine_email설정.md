# Redmine 메일 발송 설정


## Postfix 설치 

### postfix 설치
```
yum update -y
yum install -y postfix
```

### postfix 설정 변경
>vi /etc/postfix/main.cf
```
# 호스트 이름 설정
myhostname = yourdomain.com

# 메일 도메인 설정
mydomain = yourdomain.com

# 메일 발송 범위 설정
myorigin = $mydomain
inet_interfaces = all
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain

# Gmail SMTP 서버 지정
relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_security_level = may
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
smtp_use_tls = yes
```

### Gmail 앱비밀번호 설정 
- https://myaccount.google.com/apppasswords
    - 앱 이름 입력 하면 pw 생성됨

- SASL인증시 기존 계정 비밀번호가 아닌 앱 비밀번호를 사용 

### SASL 인증정보 입력 
- 다음 파일에 메일 주소 및 앱 비밀번호 입력 
> vi /etc/postfix/sasl_passwd
```
[smtp.gmail.com]:587    [your-email]@gmail.com:[your-app-password]
```

- 인증정보 파일 보호 및 해시 파일 생성 
```
sudo postmap /etc/postfix/sasl_passwd
sudo chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
rm /etc/postfix/sasl_passwd 
```

### postfix 서비스 시작 
```
systemctl enable postfix --now
```

## 메일 발송 테스트 
- mailx를 통해 메일 발송 테스트 진행 

- mailx 설치
```
yum install -y mailx 
```

- 메일 발송 테스트 진행 
```
echo "테스트 메시지 내용" | mail -s "테스트 메일 제목" [수신자]@example.com
```

- 결과 확인
    - cat /var/log/maillog


## Redmine mail 발송 설정 
- Redmine Configuration 파일 수정
    - 아래 production 부분에 다음 내용 입력

>vi /usr/local/src/redmine-4.1.0/config/configuration.yml

### smtp 사용
```
production:
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      enable_starttls_auto: true
      address: "smtp.gmail.com"
      port: 587
      domain: "smtp.gmail.com" # 'your.domain.com' for GoogleApps
      authentication: :plain
      user_name: "[발송자 메일 주소]"
      password: "[앱 비밀번호]"
```

### sendmail 사용
```
production:
  email_delivery:
    delivery_method: :sendmail
```


### Redmine 재실행 
```
# 기존 프로세스 중지 후 재기동
kill -9 [redmine_pid]
bundle exec rails server webrick -e production -b 0.0.0.0 &

or

# Apache와 연동된경우 httpd 재기동
systemctl restart httpd
```

### 발송 확인

- 관리자 계정으로 접속 
    - 관리 > 메일 알림 

- 설정 변경 후 우측 하단 `테스트메일 보내기` 로 메일 발송확인

- 메일 꼬리에 붙은 주소는 가급적 지우고 사용할것
    - URL주소가 포함된 메일의 경우 스팸으로 걸리는경우가 많음