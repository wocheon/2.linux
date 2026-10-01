## pam모듈을 이용한 Linux 계정관리

#### $\textcolor{orange}{\textsf{*Ubuntu 기준으로 작성하였음.}}$ 
#### $\textcolor{yellow}{\textsf{* 계정 삭제시 userdel -rf test 사용. (home 디렉토리까지 삭제)}}$ 

</br>

* Wheel 그룹 추가
  - Ubuntu에는 최초생성 시 wheel그룹이 없으므로 신규로 추가해야함.
```bash
group add wheel
```
</br></br>

* su 명령어 관련 규칙 적용
      
>vi /etc/pam.d/su

```bash
#auth  required  pam.wheel.so  
```
`해당라인 주석제거(15) 시 root계정 및 wheel그룹에 포함된 사용자만 su 명령이 가능해짐.`

</br></br>

- 특정계정 SSH로 직접 로그인 금지
  
>vi /etc/pam.d/sshd

```bash
auth  required  pam_listfile.so  item=user  sense=deny  file=/etc/ssh/sshusers  onerr=succed
```

>vi /etc/ssh/sshusers

```
test
```
`test계정은 ssh로 직접 접속 불가능 (단, su명령어로 전환은 가능함)`

</br></br>

* 계정 패스워드 정책 설정
  
  - 패스워드 정책 설정을위한 pam모듈 설치
```bash
apt-get install libpam-pwquality 
```

>vi /etc/pam.d/common-password

```bash
password  requisite  pam_pwquality.so  retry=3  minlen=10  ucredit=-1  dcredit=-2  ocredit=-1 lcredit=-2 #추가
password  [success=1 default=ignore]  pam_unix.so  obscure  use_authok  try_first_pass  sha512
```

`입력3회제한, 대문자 1자이상, 소문자 1자이상, 특수문자 1자이상, 숫자 2자리 이상, 총 길이 10자리 이상으로 패스워드 정책을 설정함.` </br>
`(처음 passwd로 변경하는경우 규칙 적용 없이 변경되고 passwd --expire로 강제로 만료시킨뒤 로그인하여 변경하도록 유도함.)`

</br></br>

* pam_pwquality.so 파라미터 설명 </br></br>
  - minlen=10   : 최소 패스워드 길이를 10자리 이상으로 설정
  - ucredit=-1  : 대문자 최소 1자 이상 포함해야 함.
  - dcredit=-2  : 숫자 최소 2자 이상 포함해야 함.
  - ocredit=-1  : 특수문자 최소 1자 이상 포함해야 함.
  - lcredit=-2  : 소문자 최소 2자 이상 포함해야 함.
  - try_first_pass : 처음 변경시 정책에 어긋나도 허용
     
