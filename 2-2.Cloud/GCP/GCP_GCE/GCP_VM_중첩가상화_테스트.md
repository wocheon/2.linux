# GCP VM  중첩가상화 테스트

## 테스트 목적
* Window Server VM을 BYOL(Bring Your Own License) 이미지로 생성시 반드시 단독 테넌트노드를 생성해야함. 
* 이는 비용발생이 크게 증가하므로 Window Server를 올릴 다른 방법을 도출.

<br>

## 중첩 가상화(KVM, Oracle Virtual BOX)를 이용한 Window VM 생성
* GCP 공식문서를 참고하여 테스트를 진행 <br>
	* 참고 : [GCP - 중첩된 가상화 정보](https://cloud.google.com/compute/docs/instances/nested-virtualization/overview?hl=ko)	

### 중첩 가상화 테스트 방법

* 테스트 환경 
	- OS : `Ubuntu 20.04`
	- SPEC : `n1-standard-2` (vCPU 2 / 7.5GB mem)
	- `VTX on`

1. Linux(Ubuntu) > KVM > Windows VM
2. Linux(Ubuntu) > Oracle VitualBox > Windows VM

### 테스트 작업을 위한 준비

1. VTX기능이 활성화된 이미지 준비
2. GUI 기능이 활성화된 VM <br>`(KVM, VirtualBox는 GUI환경에서 사용 가능)`


## VTX 기능 활성화된 이미지 추출
* VTX 기능이 활성화된 이미지 생성을 위해 다음과 같은 방법을 통해 인스턴스를 생성.
	
1. 디스크 생성
	- 리전 : 서울 영역 : a/b/c 중 택1
	- 소스 유형  > 이미지 선택 
		- `이미지는 생성하려는 VM의 이미지를 검색하여 사용. (커스텀이미지도 가능)`
				  		
2. 커스텀 이미지 생성 
	- Cloud console에서 다음명령어로 이미지 생성
	```bash
	gcloud compute images create virt-ubuntu1804 \
	--source-disk ubuntu-disk --source-disk-zone asia-northeast3-a \
	--licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
	```

3. 인스턴스 생성
	- 리전 : 디스크와 동일 
	- 시리즈 : N1 유형 : `n1-standard-2` (vCPU 2 / 7.5GB mem)
	- 부팅디스크 이미지 :  이전단계에서 생성한 이미지로 선택.

4. 생성 후 vtx 및 kvm 사용여부 확인 
```bash
grep -cw vmx /proc/cpuinfo #( 결과값이 0 이상으로 나와야 성공)
apt install -y cpu-checker ; kvm-ok 
```
		
## GUI 설치 및 RDP 활성화

### GUI 필요 사양
	- 최소사양 : RAM 2GB 이상
	- 관리권한 (sudo 가능 or root권한 )
	-  인터넷연결(패키지 다운로드용)

### GUI 활성화를 위한 패키지
- Xrdp : Rdp 클라이언트 (3389 포트 사용)
- gmd3 : gnome display manager


### GUI 설치
```bash
apt update && apt upgrade
apt install -y ubuntu-desktop xrdp
```	
>vi /lib/systemd/system/gdm3.service
```
[Install]
WantedBy=multi-user.target
```

### gdm3,xrdp 재시작 	

```bash
systemctl enable gdm3 
systemctl enable xrdp 
service gdm3 start
service xrdp start
```

### net-tools 설치 후 3389 port 사용 확인
```bash
apt-get install -y net-tools
netstat -lntp | grep 3389
```

### 모든사용자가 RDP 사용가능하도록 변경 
>vi /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
```bash
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
```
### xrdp 검은화면 발생방지 
>vi /etc/xrdp/startwm.sh	
```bash
unset DBUS_SESSION_BUS_ADDRESS 
unset XDG_RUNTIME_DIR 
. $HOME/.profile
```

### xrdp 서비스 재시작
```
service xrdp restart
```

### rdp 접속 확인
* `root 접속 불가하므로 개인계정 패스워드 설정하여 접속 확인`


## 테스트 1 - KVM  (Linux(Ubuntu) > KVM  > Windows)

### 패키지 설치
```bash
apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
```

### libvirtd 실행
```bash
systemctl enable --now libvirtd ; lsmod | grep -i kvm
systemctl status libvirtd
```	

### root, 사용자 계정을 libvirt 그룹에 포함
```bash
usermod -a -G libvirt root 
usermod -a -G libvirt $USER
```	

* reboot 후 virt-manager 연결 확인 
	

### ISO 파일 다운로드 
		
* SFTP 혹은 버킷을 통해 ISO파일 다운로드 		

* 버킷 오브젝트 다운로드 명령어
```
gsutill cp gs://[버킷명]/[오브젝트명] [로컬에 저장할 파일명]
```

* ISO파일 다운로드 
```
gsutil cp gs://gcp-in-ca-vm-image/Windows.iso /var/lib/libvirt/images/windows10.iso
		
gsutil cp gs://gcp-in-ca-vm-image/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso window_server_2019.iso
```			



## 테스트 2 - Oracle Virtual Box (Linux(Ubuntu) > Virtual Box  > Windows)
* GUI 설치까지 완료 후 진행.

### Virtual Box 설치

```bash
sudo apt update && sudo apt upgrade
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian focal contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

sudo apt update
sudo apt install virtualbox-6.1
```

## 테스트 결과

* 중첩가상화로 VM 생성시 성능저하가 큰폭으로 발생.
* KVM의 경우 너무 느려서 Window 설치도 힘들정도.
* Virtual Box는 KVM보다 조금 더 빠르나 실 사용할수 있는 수준은 아님.

$\textcolor{orange}{\textsf{* 실 사용에는 부적합으로 판단}}$ 

---

### 테스트 3 - OVA(virtual Box VM Export파일) or ISO image > Gcp Compute Engine

* 버킷 생성하여 ISO 이미지 및 OVA파일 업로드 
	- OVA : ubuntu 18.04 
	- ISO : Windows 10 
		
	
* Cloud console로 OVA LOAD

```bash
gcloud compute machine-images import my-machine-image \
--os=ubuntu-1404 --source-uri=gs://my-bucket/Ubuntu.ova \
--custom-cpu=2 --custom-memory=2048MB
```	
	
	
## Ubuntu Chrome 설치 
* GUI 설치 후 진행
```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

apt install ./google-chrome-stable_current_amd64.deb
```

* GUI에서 확인