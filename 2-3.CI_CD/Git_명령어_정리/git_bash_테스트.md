# GIT Bash TEST 결과 정리

### test, dev branch 추가 
```bash
$ git branch test
$ git branch dev 
```

### branch 확인
```bash
$ git branch

  dev
* main
  test
```

### 원격 branch 확인 
```
 $  git branch -r 
  origin/main
```

###  dev > test > master 로 파일 신규추가 
* dev
```
git checkout dev 
```
```
echo "dev : create file" > newfile.txt
 ```

```
git add .
git commit -m 'dev'
git push origin dev 
```

* test
```
git checkout test 
```

```
echo "test : create file and check"  >> newfile.txt
```
```
git add .
git commit 'test'
git push origin test
```

* master
```
git checkout master
echo "master : chck file"  >> newfile.txt
git add .
git commit 'master'
git push origin master 
```

* 각 브랜치에서 신규 파일 생성 시
  * dev 와 test쪽에 각각 파일 생성
  *  master에서 test, dev에 git merge master 후 push 
```
git merge test
git merge dev
git add .
git commit 'master merge'
git push origin master 
```

### master > test > dev 로 변경사항 merge 및 push

* master
```
git checkout master
```

```
$ cat newfile.txt
dev : delete
test : delete
master : chck file
```

git add .
git commit 'master_chage'
git push origin master 



* test
```
git checkout test 
git merge master 
git push origin test 
```

* dev

```
git checkout dev 
git merge test 
git push origin dev
```

```
				 |-- test_change
master_chage ----
				 |-- dev_del
```

* test
```
git checkout test 
```

```
$ cat newfile.txt
dev : delete
master : chck file
```

```
git add .
git commit -m 'test_change'
git push origin test 
```

* dev
```
git checkout dev 
```
```
$ cat newfile.txt
test : delete
master : chck file
```

```
git add .
git commit -m 'dev_del'
git push origin dev
```

## git merge test 시 충돌발생 

* merge시 충돌 발생 
  * 같은라인에 서로다른 변경사항이 있는경우 발생

* 해결법 
  1. 충돌하는 파일의 버전을 확인하여 기존 파일 삭제,<br> 최신버전의 branch에 있는 파일을 가져오기

* dev
```
rm newfile.txt 
git checkout -p test 
git add .
git commit -m '
```

2. 충돌내용 수정하여 merge 후 push

* cherrypick 사용 
  * dev > test > master 로 변경사항 업데이트를 진행
  
* dev
```
$ cat newfile.txt
dev : v3
test : v3
master : v3
```

* add 후 commit > push 

* test
```bash
git checkout test 
git log --branches --oneline # dev의 commit 내역확인
```

```
git cherry-pick [dev_commit_id]
git push origin test 
```

`*두 방법 모두 임시방편이므로 신규 업데이트 후 cherrypick으로 commit을 맞추는것이 좋음`

