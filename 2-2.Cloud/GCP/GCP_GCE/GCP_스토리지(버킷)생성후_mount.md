# GCP - Cloud Storage Mount (gcsfuse)
## Google Cloud Storage FUSE (gcsfuse)
- Google에서 지원하는 오픈소스 제품
-  Cloud Storage 버킷을 로컬 파일 시스템으로 마운트하고 액세스할 수 있게 해줌

## gcsfuse 설치 
### 참조
- https://cloud.google.com/storage/docs/gcsfuse-mount?hl=ko

### Ubuntu 또는 Debian
*  Cloud Storage FUSE 배포URL 및 공개키 추가
```bash
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```
* Cloud Storage FUSE 설치
```bash
sudo apt-get update -y
sudo apt-get install -y gcsfuse
```

### CentOS 또는 RedHat
*  Cloud Storage FUSE repo 연결 및 공개키 추가
```bash
sudo tee /etc/yum.repos.d/gcsfuse.repo > /dev/null <<EOF
[gcsfuse]
name=gcsfuse (packages.cloud.google.com)
baseurl=https://packages.cloud.google.com/yum/repos/gcsfuse-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
      https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```

* Cloud Storage FUSE 설치
```bash
sudo yum install -y gcsfuse
```


## gcsfuse로 버킷 mount 

* 버킷 목록 확인 
```bash
$ gsutil ls

gs://gcp-in-ca-daisy-bkt-asia-northeast3/
gs://gcp-in-ca-test-bucket-wocheon07/
gs://gcp-in-ca-vm-image/
gs://gcp-in-ca.appspot.com/
gs://staging.gcp-in-ca.appspot.com/
```


* 버킷을 마운트할 디렉토리 생성

```bash
mkdir /GCP_Storage
```

* 버킷 마운트 

```bash
#파일모드로 마운트
gcsfuse —file–mode=755 gcp-in-ca-test-bucket-wocheon07 /GCP_Storage
gcsfuse -o allow_other gcp-in-ca-test-bucket-wocheon07 /GCP_Storage

mount -t gcsfuse -o allow_other gcp-in-ca-test-bucket-wocheon07 /GCP_Storage
mount -t gcsfuse -o rw,user  gcp-in-ca-test-bucket-wocheon07 /GCP_Storage
```


## 권한 문제 발생 시 

- mount 후에 파일 생성이 불가한 경우 다음 방법 중 하나로 권한 인증 진행

### 권한 문제 발생 시 - API 권한 수정 
- 인스턴스 API 권한 문제로 인해 읽기만 가능하며 쓰기는 불가능 한 상태로 마운트 됨
- 변경방법 
    - 인스턴스 중지
    - 인스턴스 수정 
        - API 및 ID 관리 
            - 저장소 : 사용중지됨 > 전체로 변경
    - 인스턴스 재시작

###  권한 문제 발생 시 - 애플리케이션 기본 사용자 인증

- google-cloud-sdk 버전 확인

```bash
gcloud -v 
# 최신 버전 : 444.0.0
# gcloud 버전이 낮은 경우 로그인 불가
```

- google-cloud-sdk Update 진행
```
yum update google-cloud-sdk
```

- 애플리케이션 기본 사용자 인증정보 생성
    - 여기까지만 진행하면 사용가능함

```
gcloud auth application-default login
```

- Google Cloud CLI 승인

```
gcloud auth login
```

- 마운트 해제 후 재연결
```
fusermount -u /GCP_Storage

mount -a
```



###  권한 문제 발생 시 - 서비스 계정 인증

- 서비스 계정의 키 생성후 Json 파일을 업로드 
- --key-file 옵션으로 json 파일을 지정하여 마운트 진행



## 마운트 해제 
```
fusermount -u /GCP_Storage
```


## 영구 마운트 진행 

- fuse.conf 파일 수정 

>vi /etc/fuse.conf 
```bash
# /etc/fuse.conf - Configuration file for Filesystem in Userspace (FUSE)
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#mount_max = 1000

# Allow non-root users to specify the allow_other or allow_root mount options.
user_allow_other
# user_allow_other 주석해제
```

- 최초 접속 계정의 uid , gid 확인

```
$ id wocheon07
uid=1003(wocheon07) gid=1004(wocheon07)
```

- /etc/fstab 수정

vi /etc/fstab
```
gcp-in-ca-test-bucket-wocheon07 /GCP_Storage gcsfuse rw,_netdev,allow_other,uid=1003,gid=1004
```

- 적용확인
```
mount -a
```

## mount 시 UID, GID 옵션 부여
- mount 명령어에 UID와 GID를 부여하는 경우 <br>
gcsfuse로 마운트된 디렉토리의 모든 권한은 uid,gid를 따라간다.

- root에서 mount한 경우, root는 uid,gid 설정해도 접근이 가능 


## gcsfuse로 연결된 디렉토리에 rsync 사용 시
- rsync는 수정시간을 보존하려 하나 GCS 는 이를 지원하지 않음 
- --update --no-times 옵션 부여
    - --no-times 
        - 파일의 mtime이 다르기 때문에 파일이 항상 동기화 되지않은것처럼 rsync에서 나타남
    - --update 
        - 대상이 최신인 경우 동기화한것으로 간주함

```
rsync -avhJ  --delete --bwlimit=10240 --log-file=rsync_test.log /root/rsync_test /GCP_Storage/rsync_test/ --notime --update --progress
```