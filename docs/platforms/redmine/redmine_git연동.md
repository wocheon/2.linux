# Redmine Git 연동 

- Redmine에서 Git 연동 시 Mirror 형태로 확인가능

## Redmine Configuration 파일 수정 

- Configuration.yml 파일에 git PATH를 명시
> vi Configuration.yml
```
production:
  email_delivery:
    delivery_method: :sendmail
  scm_git_path_regexp: /usr/bin/git
```

## redmine 경로에 git_repo 클론 진행 
```
mkdir /usr/local/src/redmine-4.1.0/git_repo
cd /usr/local/src/redmine-4.1.0/git_repo
git clone --mirror https://github.com/wocheon/6.Jenkins_mvn_build_test.git 
```

## 자동 업데이트 용 스크립트 파일 생성 
> vi git_update.sh
```
#!/bin/bash
cd /usr/local/src/redmine-4.1.0/git_repos/6.Jenkins_mvn_build_test.git
git remote update
```

## 업데이트용 스크립트 Crontab 등록
```
* * * * * /usr/local/src/redmine-4.1.0/git_repos/git_update.sh
```

## redmine상에서 저장소 등록 
- 프로젝트 선택 > 설정 > 저장소 > 저장소 추가 
    - 형상관리 시스템 : Git 
    - 식별자 : Git_repo_test
    - 저장소 경로 : /usr/local/src/redmine-4.1.0/git_repos/6.Jenkins_mvn_build_test.git

- 저장후 정상 연결 확인 







