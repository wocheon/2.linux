
## 사전작업
- 가급적 redmine - apache 연동 완료 후 진행 

- redmine 설치위치 
    - /usr/local/src/redmine-4.1.0

## 필요 Ruby Gem 설치 
```
gem install httpclient
gem install rake
```

## Redmine Slack Plugin 설치 

- 공식 github에서 Plugin Clone 진행 

    - 폴더명을 redmine_slack으로 하지않으면 플러그인 찾지못하므로 주의
```
cd /usr/local/src/redmine-4.1.0/plugins
git clone https://github.com/sciyoshi/redmine-slack.git redmine_slack
```
- bundle로 redmine_slack 플러그인 설치 

```
cd redmine_slack
bundle install 
```

- 플러그인 마이그레이션 작업 수행 
```
cd /usr/local/src/redmine-4.1.0/plugins/
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

- redmine 재시작

```
systemctl restart httpd
or
bundle exec rails server webrick -e production -b 0.0.0.0 &
```

- redmine admin으로 접속 
    - 관리 > 플러그인 > Redmine Slack 플러그인이 존재하는지 확인

## 플러그인 설정 

- admin 계정 접속 
    - 관리 > 플러그인 > Redmine Slack-설정 

```
Slack URL : [Slack Webhook API URL]
Slack Channel : ""
Slack Username : redmine
Post Issue Updates? : yes
```

## 사용자 정의항목 추가 
- 사용자 정의항목을 추가하여 특정 프로젝트에서만 알림이 발생하도록 설정 

```
형식 : 목록 
이름 : Slack Channel
가능한 값들 : Slack Webhook 설정된 채널명 
```

- 프로젝트에 사용자 정의항목 할당 
    - 프로젝트 선택 > 설정 
        - Slack Webhook을 설정할 프로젝트에 Slack Channel 값을 할당
        - 알림을 사용하지 않을 프로젝트에는 (없음)으로 설정 

- 일감 등록/수정 후 알림 발생 확인 
