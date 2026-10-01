# GPU VM Nvidia Driver 설치 

## 개요
- GPU 가 1개 이상인 VM 생성시 Nvidia 드라이버를 설치해주어야함 

- GKE는 Nvidia 드라이버 자동설치 옵션이 있으나 단일 VM의 경우 직접 설치 필요 

## 설치 방법 
- 보안부팅 사용여부 혹은 특정 버전 설치 필요 여부에 따라 설치 방법이 달라질 수 있음 

-  보안부팅 사용 or 특정 버전 설치 필요시 
    - 패키지를 통해 설치 

- 보안부팅 미사용, 버전 지정 필요 x
    - 설치 스크립트로 설치 


## 설치 스크립트 사용 

- 리눅스와 윈도우 OS 의 설치 방법이 서로 다르므로 구분하여 사용 

- 지원 OS 
    - CentOS 7 및 8
    - Debian 10 및 11
    - Red Hat Enterprise Linux(RHEL) 7, 8, 9
    - Rocky Linux 8 및 9
    - Ubuntu 20 및 22

- 필요조건 
    - python3 설치
    - 2.38.0이상의 버전의 google-cloud-ops-agent가 설치된 경우 스크립트 실행 전 중지 필요 


### 설치 순서 
1. Python 3 설치 확인
```sh
$ python3 --version
```

2. 설치 스크립트 다운로드

```sh 
$ curl https://raw.githubusercontent.com/GoogleCloudPlatform/compute-gpu-installation/main/linux/install_gpu_driver.py --output install_gpu_driver.py
```
3. 설치 스크립트 실행
```
sudo python3 install_gpu_driver.py
```

- 스크립트 실행 시 어느정도 시간이 소요되므로 강제종료하지말고 기다릴것
- 스크립트가 실행되면서 자동으로 VM이 재시작됨
    - 재시작 후 다시 스크립트를 실행해줘야 설치가 마무리됨

4. GPU 드라이버 설치 확인
```
$ nvidi-smi
```

## 패키지를 통해 Nvidia-Driver 설치 
- 참고 
    - https://cloud.google.com/compute/docs/gpus/install-drivers-gpu?hl=ko#secure-boot