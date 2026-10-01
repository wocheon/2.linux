# Ubuntu VM 세팅 관련 사항 정리 

## Public Cloud 상에서 발생하는 resolv.conf 오류

- GCP/AWS 등 Public Cloud 상에서 Ubuntu VM 사용시 resolv.conf 파일 초기화로 인해 VM 내부에서 IP할당이 제대로 안되는 현상이 존재 
    - Ubunt 18.04 LTS, 20.04 LTS에서 발생확인

- Public Cloud 상에서 해당 현상이 발생하는 원인
    - 주로 VM 중지 후 재기동시에 발생 
    - /etc/resolv.conf 파일 내에는 Public Cloud의 메타데이터 서버 정보가 포함됨
        - 메타 데이터 서버 정보에 대한 수정 혹은 삭제 발생시 해당 현상 발생을 확인 

### 조치 방법 

- 메타데이터 정보 갱신 후 IP 직접 할당 
    1. 직렬콘솔 등으로 VM에 직접 접속 
    2. 동일 zone의 VM을 참고하여 /etc/resolv.conf 파일을 원복 조치
    3. dhclient 명령을 실행하여 직접 IP할당

- resolvconf 패키지 사용
    - resolv.conf 파일을 고정해주는 패키지인 resolvconf를 설치 및 설정
    - 해당 방법을 사용시 재기동하더라도 문제없이 메타데이터 서버에 연결 가능
```sh
apt install resolvconf

cat /etc/resolv.conf >> /etc/resolvconf/resolv.conf.d/head

systmectl enable resolvconf --now
```


## iptables 자동 차단 관련 
- Ubuntu 18.04 , 20.04 LTS 에서는 같은 IP상에서 SSH 접속 오류가 여러번 발생하면 pam 설정에 따라 계정 차단됨
- 이 과정에서 sshguard 에 의해 자동으로 iptables 차단 목록에 접근 IP를 추가하는 경우가 발생 
    - 해당 현상을 방지하려면 sshguard가 존재하는 경우, 해당 서비스를 stop 

```sh
systemctl disable sshguard --now
```


## 기본 패키지 설치 관련
- net-tools 
    - nestat -tnlp (프로세스별 포트 사용 현황 확인) 시  필요 

- Ubuntu 버전에 따라 Python3 혹은 Python2가 기본 설치되어있으므로 사용시 버전 확인 필요
    - pip 는 따로 설치 필요

## 기본 편집기 변경 
- Crontab는 자동으로 파일 편집기를 여는 명령의 경우 최초 실행시 편집기 선택 화면 출력됨

- visudo의 경우 기본적으로 nano 편집기를 사용하도록 설정되어있음 
    - 만약 다른 편집기로 변경이 필요하다면 다음 명령을 통해 변경 진행 


```sh
$ update-alternatives --config editor
There are 4 choices for the alternative editor (providing /usr/bin/editor).

  Selection    Path                Priority   Status
------------------------------------------------------------
* 0            /bin/nano            40        auto mode
  1            /bin/ed             -100       manual mode
  2            /bin/nano            40        manual mode
  3            /usr/bin/vim.basic   30        manual mode
  4            /usr/bin/vim.tiny    15        manual mode

Press <enter> to keep the current choice[*], or type selection number: 3
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/editor (editor) in manual mode
```