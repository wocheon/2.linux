# GIT BASH 명령어 및 사용법 정리

## Git Repository에 파일 업로드
1. gitHub에서 신규 repository 생성

2. Local에서 git bash 실행 

3. cd 로 업로드할 파일이 있는 디렉토리로 이동

4. 로컬 repository 생성 

```bash
git init 
```

 * 이름 및 이메일 설정 ( github 정보와 동일하게 )

```bash
git config - -global user.name “Your name”
git config - -global user.email “Your email address”
git config - -global - -list
```

5. github repository (외부저장소) 연결 
```bash
git remote add origin [git_repositroy_주소]
```

6. branch 지정 
```bash
git branch main
```

7. 연결 확인 
```
$ git remote -v 

origin  https://github.com/wocheon/2.Linux.git (fetch)
origin  https://github.com/wocheon/2.Linux.git (push)
```
```
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```
8. git add 및 commit 진행 
```bash
#현재 위치에 있는 파일 전부 추가
git add . 

# "upload"라는 메세지를 담은 Commit 추가
git commit -m "upload"
```
7. push 
```
git push origin master
```
* Github Repository내에 정상적으로 파일 업로드 되었는지 확인.

<br>

## Git log 관련
### Git Commit 현황 확인
* -[숫자] : 최근 내역 부터 출력할 커밋 수 설정
* -p  : 각 commit의 diff 결과 출력
>ex)
```
$ git log -2
commit 51b6f440b98d71891bbe710c321c445af2fc4387 (HEAD -> main, origin/main, origin/HEAD)
Author: wocheon <wocheon07@gmail.com>
Date:   Fri Aug 11 16:48:24 2023 +0900

    202308111648

commit 617879bbd9b56a10835bf28c5f57411d66097b12
Author: wocheon <wocheon07@gmail.com>
Date:   Fri Aug 11 16:25:06 2023 +0900

    Revert "202308111038"

    This reverts commit 2bdb5acb9245ebdb190c76c552115c8d02a7ee71.
```
### 이전 commit 내용 삭제
```
git rebase -i {제거하려고 하는 커밋의 직전 커밋 id}
```
### Git log 한줄로 확인
```
$ git log --branches --oneline
51b6f44 (HEAD -> main, origin/main, origin/HEAD) 202308111648
617879b Revert "202308111038"
1ceb5b3 202308111620
b85b498 202308111537
c2e4c9d 202308111535
b0be7d2 202308111526
```
<br>

## Git 연결 해제
### 원격저장소 연결 해제 
* 원격저장소 연결 origin 해제
```bash
$ git remote -v 

origin  https://github.com/wocheon/2.Linux.git (fetch)
origin  https://github.com/wocheon/2.Linux.git (push)

$ git remote remove origin
```
### Git init (로컬 Repository) 해제 
* ls -la 로 .git 폴더 확인 후
```bash
 rm -rf .git 
```
<br>

## Git Clone
### 원격저장소 복제 (git clone)
```
git clone <저장소 url>
```

### git clone 해제
```bash
git remote remove origin

or 

rm -rf .git
```
<br>

## Git Branch 관련

### branch 생성
```bash
 git branch test
```
### branch 삭제
```bash
$ git branch -d test

Deleted branch test (was e598c69).
```
### branch 명 변경
```bash
git branch -M main
```
### branch 변경 
```bash
git checkout [브랜치명]
```
### branch간 변경내역 merge 진행
* 현재 branch 목록
    1. master
    2. main 

* main branch에서 파일 변경 
```
git add .
git commit -m 'main change'
git push origin main
```

* checkout으로 master 브랜치로 변경
```
git merge main
git add .
git commit -m 'master change'
git push origin master
```
<br>

## Git 로그인 정보 저장 방법
```
git config --global user.email "ciw0707@naver.com"
git config --global user.name "wocheon"
git config --global user.password "[devleoper > personal access token]"
git config credential.helper store --global
```