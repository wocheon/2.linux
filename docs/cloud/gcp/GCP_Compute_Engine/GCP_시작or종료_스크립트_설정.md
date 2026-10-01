# GCP 시작/종료 스크립트 설정 
- 해당 내용에서는 Linux 서버에 대한 시작/종료 스크립트만 다룸

    - 참고 : [Windows VM에서 시작스크립트 사용](https://cloud.google.com/compute/docs/instances/startup-scripts/windows?hl=ko)

## 시작 스크립트
- 시작 스크립트란?
    - 가상 머신(VM) 인스턴스의 시작 프로세스 동안 태스크를 수행하는 파일
    - 프로젝트의 모든 VM 또는 단일 VM에 적용 가능
    - 네트워크를 사용할 수 있을 때만 시작 스크립트가 실행

- VM 수준의 메타데이터로 지정된 시작 스크립트는 프로젝트 수준의 메타데이터로 지정된 시작 스크립트를 재정의

- bash 또는 비bash 파일을 사용 가능
    
    - 비bash 파일을 사용하려면 파일 상단에 #!를 추가하여 인터프리터를 지정 필요
        
        - ex) python3 스크립트 : 스크립트 상단에 #!/usr/bin/python3를 추가

### 시작 스크립트 실행과정
```
1. 시작 스크립트를 VM에 복사

2. 시작 스크립트에 대한 실행 권한 설정

3. VM이 부팅될 때 시작 스크립트를 root 사용자로 실행
```

#### 시작 스크립트의 메타데이터 키
- 시작 스크립트는 메타데이터 키로 지정된 위치에서 VM에 전달됨

- 메타데이터 키를 통해  시작 스크립트가 로컬로 저장되는지, Cloud Storage에 저장되는지, VM에 직접 전달되는지를 지정

- 사용하는 메타데이터 키는 시작 스크립트의 크기에 따라 달라질 수 있음

|메타데이터 키|용도|실행 순서|
|:-|:-|:-|
|startup-script|로컬에 저장되거나 직접 추가된 최대 256KB의 bash 또는 비 bash 시작 스크립트 전달|초기 부팅 후 부팅할 때마다 첫 번째로 실행|
|startup-script-url|- Cloud Storage에 저장되고 크기가 256KB를 초과하는 bash 또는 비 bash 시작 스크립트 전달<br>- 입력된 url은 gsutil을 실행하는데 사용됨<br> - 공백 문자가 포함되어 있는 경우 공백을 %20 변경 필요<br>- 큰따옴표("") 사용불가|초기 부팅 후 부팅할 때마다 두 번째로 실행|


#### 시작스크립트 예시 
>vm_startup_script_CentOS7.sh

```bash
#!/bin/bash

# 초기 패스워드 설정 - 접속 후 변경
echo "root:xxxxx" | /sbin/chpasswd
echo "user01:xxxx" | /sbin/chpasswd

# selinux 해제
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config ; setenforce 0
# firewalld 해제
systemctl disable firewalld --now

# sshd 설정변경 
# - key접속 허용, Root로그인 허용
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# bastion서버 공개키 입력
mkdir /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsqnZAQKBtydbn040mWetqauZ6Kx+a7r5B4AH4gv2iPmRpSJdBsphKioxaeQ0F9+h5DMY5xfEQIW2PXc7UM9+we2OHf0pirgA1QTXPOoXBmd31Z1dMWMlIBIpXjoyLZ79XHRk9r0U7hoO9/zAUrG49csq+bfRPYZG8GtQcXnRa7mVeapTxIHeHmoiEXTOMx4qG/8iR/BfWjLn55RXXwHDHgq4pm+3NBCiZzV+EgMKLppP2tM4x6Dq8WZT5yxbTGjSypfYULiLB5dPLx2t3KuiCnQBRephhb9pzcrxQAeh7AHI5EmRs8o5W6bCK6iwTPmnRHqeIvWc9Xo2gJLqYXSZd root@gcp-ansible-test" > /root/.ssh/authorized_keys

# 기본 패키지 설치
yum install -y git curl wget bash-completion
```


#### Cloud Storage에서 Linux 시작 스크립트 전달
- Cloud Storage 내에 스크립트를 저장 후 시작 혹은 종료스크립트로 사용 가능

- Cloud Storage 에서 가져오는 경우 메타데이터 키는 startup-script-url로 고정
    - 메타데이터 사용예시 

        |키|값|
        |:-|:-|
        |startup-script-url|https://storage.googleapis.com/BUCKET/FILE|
        |startup-script-url|gs://BUCKET/FILE|

- 보안에 미치는 영향
    - 기본적으로 이를 허용하지 않는 명시적인 액세스 제어가 없는 한, <br> 프로젝트 소유자와 프로젝트 편집자는 동일한 프로젝트의 Cloud Storage 파일에 액세스 가능

    - 권한 에스컬레이션이 발생할 위험이 있으므로 주의
        - 시작 스크립트가 root로 실행된 다음 연결된 서비스 계정의 권한을 사용하여 다른 리소스에 액세스하는 경우 발생할 수 있음


## 종료 스크립트
### 종료 스크립트란?
- 인스턴스가 중지되거나 다시 시작되기 바로 전에 실행하는 스크립트

- 인스턴스를 시작하고 종료할 때 자동화 스크립트에 의존하는 경우에 유용
    - ex) 중지 혹은 삭제시 Cloud Storage로 복사하거나 로그를 백업
- VM이 중지되기 전 제한된 종료 시간 동안 실행

- 자동 확장 처리가 적용된 관리형 인스턴스 그룹에 있는 VM에 유용함

-  시작 스크립트와 매우 유사하게 작동
    - 시작스크립트의 대부분의 특징과 동일함

- Linux VM의 경우 root, Windows VM의 경우 System 계정으로 실행됨

-  VM 수준 종료 스크립트는 프로젝트 수준 종료 스크립트보다 우선 적용
        - 특정 VM에 종료 스크립트를 구성하면 이 VM에서는 프로젝트 수준 스크립트가 실행되지 않는다

- 시작스크립트와 동일하게 비 bash 스크립트 사용가능 
    - 스크립트 상단에 shebang 추가필요 ex) #!/usr/bin/python

    - 메타데이터 사용예시 

        |키|값|
        |:-|:-|
        |shutdown-script-url|https://storage.googleapis.com/BUCKET/FILE|
        |shutdown-script-url|gs://BUCKET/FILE|    

### 종료 스크립트 사용시 유의사항

- 종료 스크립트는 인스턴스가 중지되기 전에 제한된 시간 안에 실행이 끝나야함
    
    - 온디맨드 인스턴스
        - 인스턴스를 중지 또는 삭제한 후 90초
    
    - 선점형 인스턴스
        - 인스턴스 선점이 시작된 후 30초
    
    - Compute Engine이 종료 스크립트의 완료를 보장할 수 없을 때도 있음


- Windows에서는 종료 스크립트를 시작하는 데 로컬 그룹 정책을 사용
    - 설치 패키지 
        - 시스템 종료 시 스크립트를 시작하도록 로컬 그룹 정책 Computer Configuration/Windows Setting/Scripts (Startup/Shutdown) 설정을 구성



### 종료 스크립트 호출
- 다시 시작 또는 중지와 같은 특정 고급 구성 및 전원 인터페이스(ACPI) 이벤트에 의해 트리거됨

- 종료 스크립트 호출하는 경우
    1. API에 대한 instances.delete 요청 또는 instances.stop 요청으로 인해 인스턴스가 종료될 때
    2. Compute Engine이 선점 프로세스 중에 선점형 인스턴스를 중지할 때
    3. sudo shutdown 또는 sudo reboot와 같은 게스트 운영체제에 대한 요청을 통해 인스턴스가 종료될 때
    4. Google Cloud 콘솔 또는 gcloud compute 도구를 통해 수동으로 인스턴스를 종료할 때

- 인스턴스 재설정(instances().reset) 시에는 종료스크립트 호출되지 않음

### 종료스크립트 실행과정
1. 스크립트를 인스턴스의 로컬 파일로 복사합니다.

2. 실행할 수 있도록 파일의 권한을 설정합니다.

3. 인스턴스가 중지되면 파일을 실행합니다.

### 종료스크립트 예시
> backup_to_gcpbucket.sh

```bash
#!/bin/bash
hostnm=$(hostname)
today=$(date '+%y%m%d')

tar -cvf ${hostnm}_${today}.tar /root/*

gsutil mv ${hostnm}_${today}.tar gs://test-project-test-bucket-wocheon07/backup/vm_backups/
```

- 메타데이터로 등록 후 확인
shutdown-script-url - gs://test-project-test-bucket-wocheon07/backup/backup_to_gcpbucket.sh