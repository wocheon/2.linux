# Shell Script 기본 문법 정리

## OS 별 `sh` - Symbolic Link 
CentOS

```bash
$ which sh
/usr/bin/sh

$ readlink -f /usr/bin/sh
/usr/bin/bash
```

### Ubuntu 
```bash
$ which sh
/bin/sh

$ readlink -f /usr/bin/sh
/bin/dash
```

- 이로 인해 Ubuntu에서는 Centos에서 사용하던 스크립트가 에러가 나는경우가 있음.

- 심볼릭 링크를 /bin/bash로 변경 혹은 bash [script파일] 형태로 실행하면 동일한 결과값 나옴

## 변수의 범위 (scope)

### 전역변수(global) 
- 쉘스크립트 내부 어디에서나 사용할수 있는 변수
- 기본적으로 스크립트에서 정의한 모든 변수는 전역변수이다.
- 함수 외부에서 정의 된 변수 , 함수외부에서도 사용가능하다.

```bash
function func1 {
        val1=$[ $val1 * 2 ]
}

read -p " value :? " val1
func1

val1=$[ val1 -1 ]
echo $val1 
#> 함수 밖에서 연산도 가능함
```

### 지역변수 (local ) 변수
- 함수안에서만 사용하는 변수로 선언
- local이라는 키워드를 사용함

```bash
#!/bin/bash
function func1 {
        local temp=$[val1 +5]
        result=$[temp *2]
}

temp=4
val1=6
func1
echo $temp
echo $val1
echo $result

if [ $temp -gt $val1 ]; then
echo " temp > val1"
else
echo " val1 > temp"
fi
#> local 키워드를 사용해서 지역변수로 선언
# 함수에서만 temp값이 변화하고 함수 밖에는 영향을 주지않는다.
```

## 변수 선언

### 문자열 선언
- 작은따옴표로 감싸진 문자열은 변화 없이 그대로 출력
- 큰따옴표 안에 넣으면 변수가 실제 값으로 치환된 후 출력

```bash
#!/bin/bash

test="var_test"
test2="var_test2"

var="$test"
var2='$test2'

echo $var
echo $var2
```
> 결과
```bash
var_test
$test2
```

### 특수문자 입력이 필요한 경우
- 큰따옴표내에서 특수문자를 치환 하지않고 출력해야하는 경우
    - 따옴표 , $ , & , * , \ 등
- 특수문자 앞에 백슬래시 (\\)를 입력
```bash
#!/bin/bash

test="var_test"
test2="var_test2"

var="\$test"
var2='$test2'

echo $var
echo $var2
```
> 결과
```bash
var_test
$test2
```

### Command 결과 값을 변수에 입력
- $(명령어) 혹은 \`명령어\` 형태로 사용

```bash
#!/bin/bash

date=`date +%y%m%d`
hostname=$(hostname)
echo "$date - $hostname"
```

### 변수 구분자 
- ${변수명} 형태로 변수 지정 가능
```bash
#!/bin/bash

date=`date +%y%m%d`
hostname=$(hostname)
echo "${date} - ${hostname}"
```




#### 숫자 계산
- 숫자 계산시 expr 명령어 혹은 변수를 대괄호로 묶어서 연산을 진행
- expr 사용하여 곱셈을 하는 경우 * 앞에 백슬래시 입력 필요


- expr 사용
```bash
#!/bin/bash
var1=10
var2=`expr $var1 + 10`
var3=`expr $var1 - 10`
var4=`expr $var1 \* 10`
var5=`expr $var1 / 10`

echo "var1 : $var1"
echo "var2 : $var2"
echo "var3 : $var3"
echo "var4 : $var4"
echo "var5 : $var5"
```

> 결과

```bash
var1 : 10
var2 : 20
var3 : 0
var4 : 100
var5 : 1
```

- 대괄호 사용

```bash
#!/bin/bash
var1=10
var2=$[ var1 - 5 ]
var3=$[ var1 + 5 ]
var4=$[ var1 * 5 ]
var5=$[ var1 / 5 ]

echo "var1 : $var1"
echo "var2 : $var2"
echo "var3 : $var3"
echo "var4 : $var4"
echo "var5 : $var5"
```
> 결과
```bash
var1 : 10
var2 : 5
var3 : 15
var4 : 50
var5 : 2
```



### 배열
- 문자열 목록을 하나의 변수로 설정하여 사용
```bash
#!/bin/bash
array=(1 "A" 2 "B" 3 "C")

# 인덱스 미지정 - 첫번째 값 출력
echo $array

# 배열중 첫번째 값을 출력
echo ${array[0]}

# 배열중 두번째 값을 출력
echo ${array[1]}

# 배열중 세번째 값을 출력
echo ${array[2]}

# 배열에 할당된 모든 값을 출력
echo ${array[@]}
```
>결과
```bash
$ sh test_arr.sh

1
1
A
2
1 A 2 B 3 C

```


## 매개 변수 

| 문자 | 설명 |
|:-:|:-|
|$0	|실행된 스크립트 이름|
|$1|- 입력 파라미터<br>- $1 $2 $3 인자 순서대로 번호가 부여된다.<br> - 10번째부터는 "{}"감싸줘야 함<br>- 사용 예시) sh test.sh "test" "test2"|
|$*|모든 입력 파라미터 값을 하나의 문자열로 출력|
|$@|모든 입력 파라미터 값을 하나의 배열로 출력|
|$#|매개 변수의 총 개수|
|$$|현재 스크립트의 PID|
|$?|- 최근에 실행된 명령어, 함수, 스크립트 자식의 종료 상태<br> - 0 : 이전 명령어 정상 종료|
|$!|최근에 실행한 백그라운드(비동기) 명령의 PID|
|$-|현재 옵션 플래그|
|$_|지난 명령의 마지막 인자로 설정된 특수 변수|


### \$@ 와 \$* 비교

- 입력받은 모든 파라미터 값을 $@ 는 배열  $* 는 문자열로 출력 

```bash
#!/bin/bash
echo "================="
echo "\$@ section"
echo "================="
for param in "$@"
do
	echo $param,
done

echo "================="
echo "\$* section"
echo "================="
for param in "$*"
do
	echo $param,
done
```

>실행 결과

```bash
$ sh test2.sh 1 2 3 4 5

=================
$@ section
=================
1,
2,
3,
4,
5,
=================
$* section
=================
1 2 3 4 5,
```



<br>

- 매개 변수 확장

|표현식|예시|설명|
|:-:|:-|:-|
|${변수}|echo ${string}|\$변수와 동일하지만 \{\} 사용해야만 동작하는 것들이 있음| 
|${변수:위치}|echo ${string:4}|위치 다음부터 문자열 추출|
|${변수:위치:길이}|echo ${string:4:3}|위치 다음부터 지정한 길이 만큼의 문자열 추출|
|${변수:-단어}|echo ${string:-HELLO}|변수 미선언 혹은 NULL일때 기본값 지정, 위치 매개 변수는 사용 불가|
|${변수-단어}|echo ${string-HELLO}|변수 미선언시만 기본값 지정, 위치 매개 변수는 사용 불가|
|${변수:=단어}|echo ${string:=HELLO}|변수 미선언 혹은 NULL일때 기본값 지정, 위치 매개 변수 사용 가능|
|${변수=단어}|echo ${string=HELLO}|변수 미선언시만 기본값 지정, 위치 매개 변수 사용 가능| 
|${변수:?단어}|echo ${string:?HELLO}|변수 미선언 혹은 NULL일때 단어 출력 후 스크립트 종료|
|${변수?단어}|echo ${string?HELLO}|변수 미선언시만 단어 출력 후 스크립트 종료| 
|${변수:+단어}|echo ${string:+HELLO}|변수 선언시만 단어 사용| 
|${변수+단어}|echo ${string+HELLO}|변수 선언 혹은 NULL일때 단어 사용| 
|${#변수}|echo ${#string}|문자열 길이| 
|${변수#단어}|echo ${string#a*b}|변수의 앞부분부터 짧게 일치한 단어 삭제| 
|${변수##단어}|echo ${string##a*b}|변수의 앞부분부터 길게 일치한 단어 삭제| 
|${변수%단어}|echo ${string%b*c}|변수의 뒷부분부터 짧게 일치한 단어 삭제| 
|${변수%%단어}|echo ${string%%b*c}|변수의 뒷부분부터 길게 일치한 단어 삭제| 
|${변수/찾는단어/변경단어}|echo ${string/abc/HELLO}|처음 일치한 단어를 변경| 
|${변수//찾는단어/변경단어}|echo ${string//abc/HELLO}|일치하는 모든 단어를 변경| 
|${변수/#찾는단어/변경단어}|echo ${string/#abc/HELLO}|앞부분이 일치하면 변경| 
|${변수/%찾는단어/변경단어}|echo ${string/%abc/HELLO}|뒷부분이 일치하면 변경| 
|\${!단어*}, ${!단어@}| echo \${!string*}, echo ${!string@}|선언된 변수중에서 단어가 포함된 변수 명 추출|


<br >



## 조건문  연산자 목록
- 조건문 내에서 사용가능한 연산자 
- 해당 연산자로 조건이 참인지 아닌지를 판단하여 분기를 지정

### 파일 테스트 연산자
|연산자| 조건 |
|:-:|:-|
|-e|파일이 존재|
|-d|디렉토리 존재|
|-f|보통 파일이면 참(디렉토리나 디바이스 파일이 아님)|
|-s|파일 크기가 0 이 아님|
|-b|파일이 블럭 디바이스(플로피나 시디롬 등등)|
|-c|파일이 문자 디바이스(키보드, 모뎀, 사운드 카드 등등)|
|-p|파일이 파이프|
|-h|하드 링크|
|-L|심볼릭 링크|
|-S|파일이 소켓|
|-t|스크립트의 표준입력([ -t 0 ])이나 표준출력([ -t 1 ])이 터미널인지 아닌지를 확인|
|-r|사용자가 읽기 퍼미션을 갖고 있음|
|-w|사용자가 쓰기 퍼미션을 갖고 있음|
|-x|사용자가 실행 퍼미션을 갖고 있음|
|-g|파일이나 디렉토리에 set-group-id(sgid) 플래그 세트|
|-u|파일에 set-user-id(suid) 플래그가 세트되어 있음|
|-k|스티키 비트(sticky bit)가 세트|
|-O|파일 소유자가 자신|
|-G|그룹 아이디가 자신과 같음|
|-N|마지막으로 읽힌 후에 변경됐음|
|f1 -nt f2|f1 파일의 수정시간이 f2 파일보다 최신|
|f1 -ot f2|f1 파일이 수정시간이 f2 파일보다 이전|
|f1 -ef f2|f1 파일과 f2 파일이 같은 파일을 하드 링크|


### 산술 비교 연산자 

|연산자|조건|
|:-:|:-|
|-eq|두 수가 같음(equal)|
|-ne|두 수가 같지 않음(not equal)|
|-gt|왼쪽이 오른쪽보다 더 큼(greater than)|
|-ge|왼쪽이 오른쪽보다 더 크거나 같음(greater than or equal)|
|-lt|왼쪽이 오른쪽보다 더 작음(less than)|
|-le|왼쪽이 오른쪽보다 더 작거나 같음(less than or equal)|

### 산술 비교 연산자 - 부등호
- 부등호 사용시 이중 소괄호 필요

|연산자|조건|예시|
|:-:|:-|:-|
|<|왼쪽이 오른쪽보다 더 작음 |if (( "$a" < "$b" ))|
|<=|왼쪽이 오른쪽보다 더 작거나 같음 |if (( "$a" <= "$b" ))|
|>|왼쪽이 오른쪽보다 더 큼 |if (( "$a" > "$b" ))|
|>=|왼쪽이 오른쪽보다 더 크거나 같음| if (( "$a" >= "$b" ))|


### 문자열 비교 연산자
|연산자|조건|예시|
|:-:|:-|:-|
|-z|문자열이 "null"임. 즉, 길이가 0|
|-n|문자열이 "null"이 아님.|
|`=`|두 문자열이 같음|if [ "$a" = "$b" ]|
|`!=`|두 문자열이 같지 않음|if [ "$a" != "$b" ]|
|`==`|두 문자열이 같음 ('=' 와 같은 동작)| if [ "$a" == "$b" ] <br><br>`# $a 가 "z"로 시작하면 참(패턴 매칭)`<br>if [[ $a == z* ]] <br><br>`# $a 가 z* 와 같다면 참`<br>[[ $a == "z*" ]]  |


### 문자열 비교 연산자 - 부등호
- 부등호는 이중 대괄호에서 이스케이프 없이 사용할 수 있다. 

|연산자|조건|예시|
|:-:|:-|:-|
|< |왼쪽이 오른쪽보다 아스키 알파벳 순서에서 더 작음 <br>'<' 를 [ ] 에서 쓰려면 이스케이프 시켜야 한다.|if [[ "$a" < "$b" ]] <br>if [ "$a" \\< "$b" ]|
|> |왼쪽이 오른쪽보다 아스키 알파벳 순서에서 더 큼<br>'>' 를 [ ] 에서 쓰려면 이스케이프 시켜야 한다.|if [[ "$a" > "$b" ]]<br>if [ "$a" \\> "$b" ]|


## 조건문 - IF
- 조건문이 들어가는 대괄호([,]) 양쪽 사이에 공백이 한 칸 꼭 들어가야 한다.

### IF 문 사용 예시

#### IF - ELSE

```bash
#!/bin/bash
var="ok"

IF [ $var == "ok" ]; then
    echo "ok"
else 
    echo "fail"
fi
```

#### IF - ELSE IF

```bash
#!/bin/bash
var="no"

if [ $var == "ok" ]; then
    echo "ok"
elif [ $var == "no" ]; then
        echo "no"
else
    echo "fail"
fi
```
#### IF - AND / OR

- AND

```bash
#!/bin/bash
var1="ok"
var2="ok"

if [ $var1 == 'ok' ] && [ $var2 == 'ok' ]; then
    echo "ok"
else
    echo "fail"
fi
```

- OR

```bash
#!/bin/bash
var1="ok"
var2="ok"

if [ $var1 == 'ok' ] && [ $var2 == 'ok' ]; then
    echo "ok"
else
    echo "fail"
fi
```
## 조건문 - CASE 
- test string d이 패턴과 일치하면 해당 패턴 이후의 커맨드를 실행
- ;; (세미콜론 두개) 를 통해 제어권 종료

- case문 패턴

|패턴|내용|
|:-:|:-|
|*|임의의 모든 문자열 (패턴에 일치하는것 제외함)|
|?|임의의 한글자 문자열|
|[...] |문자 클래스 . 한글자씩일치하는지 여부를 확인(and연산) <br> ex) [ABC]|
| \||or연산, 분리조건을 이용함|

>예시
```bash
case test-string in
        pattern-1)
        command1
        ;;
        pattern-2)
        command2
        ;
        pattern-3)
        command3
        ;;
        *)
        command4
        ;;
esac
```


- 예제 - case문으로 계산기 스크립트 작성

```bash
#! /bin/bash
read -p "enter A : " A
read -p "enter B : " B
read -p " select operator  1)+  2)-  3)*  4)/ " select
case $select in
        1|'+')
        echo `expr $A + $B`;;
        2|'-')
        echo `expr $A - $B`;;
        3|'*')
        echo `expr $A \* $B`;;
        4|'/')
        #echo `expr $A / $B`;; 소수점 계산 불가능
         echo "$A $B"| awk '{printf"%.3f",$1 / $2}' && echo ;; 
        *)
        echo "wrong answer";;
esac
```


## 조건문 - FOR

- 배열 변수를 입력

```bash
# * : 현재작업디렉토리에 있는 모든파일을 배열로 지정( 숨김파일제외)
#! /bin/bash
var=("A" "a" "B" "b" "C" "c")

for i in ${var[@]}; do
    echo"$i"
done
```

- 현재 위치에있는 파일 목록 출력

```bash
#! /bin/bash
# * : 현재작업디렉토리에 있는 모든파일을 배열로 지정( 숨김파일제외)
for i in *
do
        if [ -d $i ]; then
        echo -e "\E[0;43m $i is Directory \E[0m"
        elif [ -f $i ]; then
        echo -e "\E[0;42m $i is File \E[0m"
        fi
done
```



## 조건문 - WHILE
- if ~then 과 for문 사이에 있음
- test command를 정의 후, test command의 종료 상태가 false가 나올때까지 커맨드를 반복
    - testcommand가 true일때는 반복, false인경우 종료


- 기본형태
```
while test-command 
do
        command
done
```

- 예제 - 10초 카운트 진행
```bash
var1=10
while [ $var1 -gt 0 ]; do
    echo "this is test $var1"
    var1=$[ var1 - 1 ]
    sleep 1
done
```

- while은 조건문을 만나야만 동작여부를 결정한다.

```bash
#echo $var1 명령이 조건문위에있으므로 0까지 나오게된다
var1=10
while echo $var1
     [ $var1 -ge 0 ]
do
    echo "this is test $var1"
    var1=$[ var1 - 1 ]
    sleep 1
done
```


### for문과 while문의 차이점
- for 
    - argumnet list가 존재해서 하나씩 추출하여 반복
    - 반복시킬 횟수를정해두고 그만큼을 반복

- while 
    - testcommand가 존재하여 true면 반복 , false면 중지 
    - 원하는 결과값이  나올때까지 반복


## 조건문 - UNTIL
- while 과 형태는 같으나 정 반대로 동작

- 기본형
```
until testcommand
 do 
        command
done
```

- while과의 차이점
    - while 
        - testcommand > true > 반복 > false > 종료
    - until 
        - testcommand > false > 반복 > true > 종료


untill을 사용
name이라는 변수 지정
와 맞으면 탈출 그렇지않으면 변수를 입력받는 게임을 만드시오

- 예제 -  이름 맞추기 

```bash
#!/bin/bash
echo  'what is "name"? '
read pswd

until [ $pswd = "ciw0707" ]; do
    echo -e "\E[0;31mwrong answer! \E[0m" 
    echo  'what is "name"?' 
    read pswd
done

echo -e "\E[0;32mcollect! \E[0m" 
```



## 중첩반복문 
- 예제 - 구구단 계산기
```bash
#!/bin/bash
#ex) 몇단까지 계산하겠습니까?  =>  1~5단까지 계산
read -p "몇단까지 계산하시겠습니까 ? : " a
var1=1
while [ $a -ge $var1 ]
do
echo "$var1 단" 
        for (( b=1; b<=9; b++ ))
                do
                echo "$var1 * $b = `expr $var1 \* $b`"
                done
var1=$[var1+1]
done
```

## | / & / && / ;

### 파이프 (|)
- 왼쪽 커맨드의 standard ouput과 오른족 커맨드의 standard inputd을 연결한다.

>사용 예시
```bash
ls -lrth | grep *.txt
ls -lrth | grep *.txt | gawk '{print $4}'
```


### & / && / ;
- ;
    - 앞의 명령어가 실패해도 다음 명령어가 실행

- & 
    - 앞의 명령어를 백그라운드로 돌리고 동시에 뒤의 명령어를 실행

- && 
    - 앞의 명령어가 성공했을 때 다음 명령어가 실행

>사용 예시
```bash
$ ls -lrth ./*
----r--r--    1 42949672 42949672       0 Sep 11 15:22 ./test

# &&
# 앞 명령어가 실패하여 ls 실행 x
$ cat test.txt && ls -l
cat: can`t open 'test.txt': No such file or directory

# ;
#  앞 명령어가 실패해도 ls 실행 
$ cat test.txt ; ls -l
cat: can`t open 'test.txt': No such file or directory
total 0
----r--r--    1 42949672 42949672         0 Sep 11 15:22 test

# &
#  앞 명령어는 백그라운드로 실행 후 ls 실행 
$ cat test.txt & ls -l
[1] 1607
cat: can`t open 'test.txt': No such file or directory
total 0
----r--r--    1 42949672 42949672         0 Sep 11 15:22 test
```

## Redirection
- command > filename와 같은 형태로 사용
- 파일을 읽어서 표준 입력으로 전달 혹은 표준출력을 파일로 저장
- 파일 대신 명령의 결과를 입력, 출력할 수도 있습니다.
- &를 붙이면 표준 에러도 함께 전달합니다.

- redirection 구분 

|Redirection|내용|
|:-:|:-|
|<|파일 읽기|
|>|파일 쓰기(overwrite)|
|>>|파일 쓰기(insert)|	

```bash
# 파일 입력
$ command < infile

# 파일 출력 
$ command > outfile
$ command >> outfile

# 파일 출력 + 표준에러 전달
$ command >& outfile
$ command >>& outfile
```
## 파일 디스크립터 
|파일디스크럽터|명칭|설명|
|:--:|:-:|:-|
|0 | STDIN | 표준 입력|
|1 | STDOUT| 표준 출력|
|2 | STDERR| 표준 에러|


```bash
# 표준 출력값을 파일에 입력
$ ls -l test.sh 1>lslog
----r--r--    1 42949672 42949672       214 Sep 11 15:31 test.sh

$ cat lslog


# 표준 에러값을 파일에 입력
$ ls -l test 2>lslog

$ cat lslog
ls: test: No such file or directory


# 표준 출력, 에러를 동일 파일에 입력 
$ ls -l test > lslog 2>&1
$ ls -l test.sh >> lslog 2>&1

$ cat lslog
ls: test: No such file or directory
----r--r--    1 42949672 42949672       214 Sep 11 15:31 test.sh


# 표준에러는 버리고 파일에 입력
$ ls -l test > lslog 2> /dev/null
$ ls -l test.sh >> lslog 2> /dev/null

$ cat lslog
----r--r--    1 42949672 42949672       214 Sep 11 15:31 test.sh
```

## exec
- 스크립트 내에서 출력값을 전달하게끔 명시하는 방법
- 리다이렉션 및 파일디스크럽터 사용가능함
```bash
#!/bin/bash
exec >> test.log 2>&1
echo "aa"
echo "bb"
asdf
echo "cc"
exec > /dev/tty
```

>cat test.log
```bash
aa
bb
test.sh: line 4: asd : command not found
cc
```
### 표준 입력 사용법 
- EOF 
    - End Of File의 약자
- 표준 입력을 사용하여 파일에 내용을 추가

```bash
$ cat << EOF >> testfile
> a
> b
> c
> d
EOF

$ cat testfile
a
b
c
d
```

- 표준 입력을 통해 연속되는 명령을 실행
```bash
#!/bin/bash
pass="welcome1"

su << EOF
${pass}
yum install -y httpd
EOF
```


## SED 편집기
- 일반적인 대화형 텍스트 편집기와는 반대개념인 스트림 방식의 편집기
- 스트림 방식 
    - 데이터를 처리하기전에 데이터 처리 형식을 입력받고 그 형식에 따라서 처리하는 방식

- 동작방식 
1. 한번에 데이터 한줄씩을 읽는다.
2. 읽은 데이터를 규칙과 대조
3. 명령에서 지정된 규칙에 따라 스트림의 형식으로 변경한다.
4.  STDOUT으로 출력
    - 파일 자체는 바뀌지않는다 
    - -i 옵션을 쓰면 실제 파일 변경가능

- 사용예제
```bash
sed 's/nologin/hello/; s/sbin/abin/' passwd 
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config 
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
```



## gawk (awk)

awk : 유닉스 awk 편집기의 GNU버전 
sed 편집기보다 더 나은 편집환경을 제공한다.
1. 데이터를 저장하는 변수 정의가능
2. 산술 문자열 연산가능
3. loop , if-then같은 로직을 추가가능
- 스크립트는 괄호로 정의한다.

- 기본형태 
    - STDOUT | gawk 'pattern' 
>예시
```bash
gawk 'pattern' file
gawk '{action}' file
gawk 'pattern {action}' file
```

### awk 의 동작원리
1. 입력된 줄에 $0라는 내부변수에 그줄을 넣는다 
    - 줄을 읽을때마다 그 줄을 $0에 할당시킴

    - 각 줄은 레코드라고 부르기도한다.
        - 개행 문자를 통해서 레코드를  구분

2. 각줄은 공백으로 구분된 필드로 쪼개어 진다.
    - 필드는 $1으로 시작되는 숫자 변수에 저장

3. gawk 는 FS라는 변수에 공백을 구분하는 변수를 할당한다 
    - 기본값은 space

4. gawk 가 필드를 출력할때 action에서 print라는 함수를 사용함
    - OFS변수에 다른값을 할당하면 출력시 공백이 아닌 다른 문자로 필드를 구분
    >ex) cat passwd | gawk -F: '{print $1}' passwd

5. gawk가 결과를 출력한후, 다음줄을 갖고온다 


### 필드와 레코드 분리변수
- FILEDWIDTHS 
    - 데이터 필드의 정확한 폭을 정의
- FS 
    - 입력필드 구분 (커맨드라인  -F)
    > ex) gawk 'BEGIN{FS=","}{print $1}' data3

- RS 
    - 입력 레코드 구분
- OFS 
    - 출력 필드 구분 
    >ex) gawk 'BEGIN{FS=","; OFS="/";} {print $1,$2;}' data3

- ORS 
    - 출력 레코드 구분

- BEGIN 
    - FS,OFS 등을 지정할수 있다.
    
    - 형식 
        - BEGIN{FS="," OFS="-"}


- $0 
    - 텍스트 전체
- $1 
    - 텍스트 줄에서 첫번째 데이터 필드
- $n 
    - 텍스트 줄에서 n번째 데이터 필드



### gawk 패턴 예시

|패턴|출력|
|:-:|:-|
|gawk '/mary/' data|data파일에서 mary라는 패턴을가진 데이터 출력|
|gawk '{print $1}' data|data파일에서 1번째 필드 데이터 출력|
|gawk '/sally/ {print $1}' data|data파일의 1번째 필드에서  mary라는 패턴을가진 데이터 출력|
|gawk '/sally/ {print $1,$2}' data|data파일에서 mary라는 패턴을가진 데이터를 1,2번필드 까지 출력|
|df \| gawk '$4>=1881964' |4번째 필드가 1881964보다 큰값을 출력|

- 세미콜론을 이용하면 여러 명령 동시에 호출가능
>ex)
```
gawk -F : '{$1="apollo" ; print $1,$2 }' passwd 
```

- 정규표현식 문법을 사용할때 / /사용
>ex)
```
cat passwd | gawk '/nologin$/' 
cat passwd | gawk '/^mail/'
```    



### 파일을  이용한 호출

>vim script
```bash
{ print $1" 's home d is" $6 }
```

> 파일로 호출
```bash
gawk -F : -f script passwd
```


### awk 정규 표현식 메타문자

>예시용 파일
```bash
$ cat awk_test.txt
abc 1
bcd 2
cde 3
def 4
efg 5
fgh 6
abc 7
abcd
abcde
abcdef

$ cat awk_test_2.txt
abc
acc
adc
bac
bbc
bcc
cac
cbc
ccc
```

|메타문자|내용|예시|
|:-:|:-|:-|
|^| 문자열의 맨처음과 일치|gawk '/^a/' awk_test.txt|
|$|문자열의 맨 끝과 일치|gawk '/1$/' awk_test.txt|
|.|줄바꿈(\n)을 제외한 임의의 모든 문자(공백 포함)| gawk '/.e./' awk_test.txt|
|*|선행문자와 같은 문자의 0개 혹은 임의개 대응| gawk '/a.\*d/' awk_test.txt
|?|선행문자와 같은 문자의 1개 와 대응| gawk '/ac?/' awk_test_2.txt
|+|선행문자와 최소 1개 이상 대응|gawk '/d+/' awk_test.txt
|[ABC]|ABC중 한 문자와 일치| gawk '/[abc]/' awk_test.txt
|^[ABC]|맨앞글자가 ABC중 하나|gawk '/^[abc]/' awk_test.txt
|[A-Z]| A~Z중 하나이상 포함되는 경우를 검색 |gawk '/[1-5]/' awk_test.txt
|A\|B|OR 조건으로 검색| gawk '/ab\|ac/' awk_test_2.txt
|[^abc]|abc가 아닌 것을 검색 |gawk '/^[^abc]/' awk_test.txt

```
[ABC]? : [ABC][ABC] 또는 [ABC]
[ABC]+ : [ABC][ABC] 또는 [ABC][ABC][ABC]
```

- match 연산자
- `~` 
    - 레코드나 필드내에서 일치하는 패턴을 찾음

>ex
```bash
#첫번째 필드가 ly로 끝나지않는 패턴만을 출력
 gawk '$1 !~ /ly$/' data 
```
  
### 기타 gawk 사용예제
 ```
1.  gawk '/west/' data4
2.  gawk '/^north/' data4
3.  gawk '/^[no,so]/' data4
4.  gawk '{OFS=" "}{print $2,$3}' data4
5.  gawk '{OFS=""}{print $2,$3}' data4\
6.  gawk '/^[n,s]/{print $1}' data4
7.  gawk '$5 ~/\.[7-9]$/' data4
8.  gawk '$2 !~/E/{print $1,$2}' data4
9.  gawk '$3 ~/^Joel/{print $3" is a nice guy"}' data4
10. gawk '$8 ~/../ {print $8}' data4
11. gawk '$4 ~/Chin$/ {print "The price is $"$8"."}' data4
12. gawk -F':' '$7 ~ /^5/{print $7}' ex2
13. gawk -F':' '$2 ~ /CT/ {print $1, $2}' ex2
14. gawk -F':' '$7<5 {print $4, $7}' ex2
15. gawk -F':' '$5>.9  {print $1,$6}' ex2
```
