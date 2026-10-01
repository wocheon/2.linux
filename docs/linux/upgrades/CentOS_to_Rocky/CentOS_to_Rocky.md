# CentOS To Rocky

## 개요
- CentOS7 EOS로 인하여 Rocky Linux로 업데이트를 진행 
- 별도 스크립트를 실행하는 방식으로 진행 


## CentOS7 to Rocky8
- `migrate2rocky` 스크립트는 CentOS8 부터 정상적으로 지원되므로 CentOS7에서는 `leapp`을 사용하여 업데이트 진행
- 소요 시간 
    - 약 1시간 이상
```bash
# CentOS 7.9  TO Rocky Linux 8

# (7.9 -> 9 추출) - 7.x 중 7.9인지 확인 목적
export centos_v=$(cat /etc/centos-release | gawk '{print $4}' | gawk -F'.' '{print $2}' )

# 기본 패키지 모두 최신 버전으로 업데이트 (선택)
yum update -y                   

# AlmaLinux(ELevate 프로젝트)의 패키지 저장소 RPM 설치
# 이 저장소 내에 마이그레이션 관련 툴(leapp 등)이 포함됨
sudo yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el7.noarch.rpm

# ELevate 프로젝트 기반의 리눅스 업그레이드 도구인 leapp 설치
sudo yum install -y leapp-upgrade leapp-data-rocky

# leapp을 사용하여 업그레이드 전 사전검사(시스템 호환성, 의존성 등 확인)
sudo leapp preupgrade

# root SSH 접속 허용 설정 추가 (마이그레이드 중 필요할 수 있음)
echo PermitRootLogin yes | sudo tee -a /etc/ssh/sshd_config

# leapp에서 "remove_pam_pkcs11_module_check.confirm=True" 옵션을 자동으로 승인
# 이 옵션은 보통 업그레이드 중 PAM PKCS#11 모듈 제거 동의를 의미
sudo leapp answer --section remove_pam_pkcs11_module_check.confirm=True

# 본격 업그레이드 명령 실행 (CentOS 7 -> Rocky Linux 8 실제 마이그레이션 진행)
sudo leapp upgrade

# 업그레이드 후 reboot (reboot 시 패키지 업데이트가 진행되므로 오래걸릴수 있음)
reboot

# 재부팅 후 OS 버전 확인
$ cat /etc/os-release

NAME="Rocky Linux"
VERSION="8.10 (Green Obsidian)"
ID="rocky"
ID_LIKE="rhel centos fedora"
VERSION_ID="8.10"
PLATFORM_ID="platform:el8"
PRETTY_NAME="Rocky Linux 8.10 (Green Obsidian)"
ANSI_COLOR="0;32"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:rocky:rocky:8:GA"
HOME_URL="https://rockylinux.org/"
BUG_REPORT_URL="https://bugs.rockylinux.org/"
SUPPORT_END="2029-05-31"
ROCKY_SUPPORT_PRODUCT="Rocky-Linux-8"
ROCKY_SUPPORT_PRODUCT_VERSION="8.10"
REDHAT_SUPPORT_PRODUCT="Rocky Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="8.10"
```



## CentOS8 to Rocky8
- CentOS8부터는 `migrate2rocky` 스크립트를 사용하여 전환 가능 

```bash
# migrate2rocky 스크립트 다운로드
curl -O https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh

# 스크립트 실행권한 부여
chmod +x migrate2rocky.sh

# 스크립트 실행 (Centos > Rocky8)
# -r 옵션으로 업데이트할 Rocky 리눅스 버전 지정 가능
sudo ./migrate2rocky.sh -r 8

# 스크립트 실행 완료 후 재기동 
reboot

# 재부팅 후 OS 버전 확인
cat /etc/os-release
```


## OS 업데이트 후 주요 점검 사항

1. OS 버전 확인 및 시스템 상태 점검
    - OS 버전 정상 업그레이드 여부 확인
    - 커널 버전 확인 및 필요시 커널 업그레이드 진행
    ```sh
    cat /etc/os-release
    uname -r
    ```

2. 필수 서비스 및 데몬 상태 점검
    - 네트워크, SSH, 방화벽 등 서비스 정상 구동 여부 확인
        - 실패한 서비스가 있으면 로그 분석 및 재설정
    ```sh
    systemctl list-units --failed
    systemctl status sshd
    systemctl status network
    ```        

3. 네트워크 설정 확인 및 복구
    - 인터페이스 명칭 변경으로 인한 문제 발생여부 확인 (예: eth0 → ens...)
    - /etc/sysconfig/network-scripts/ 내 네트워크 스크립트 및 nmcli 설정 확인
    - IP, DNS, 라우팅 문제 여부 점검

4. 패키지 및 의존성 문제 해결
    - 업그레이드 중 남은 패키지 의존성 문제 정리
    - 누락/충돌 패키지 수동 재설치 혹은 제거
    ```sh
    sudo dnf distro-sync -y
    sudo dnf check
    ```
5. 커스텀 설정 및 구성파일 점검
    - /etc 주요 설정파일 비교 점검
    - SELinux 설정 확인 및 필요 시 조정
    - 사용자 권한, 그룹, 계정 설정 정상 여부 확인


6. 부트로더 및 GRUB 설정 확인
    - 부팅 문제 방지를 위해 GRUB 설정 점검 및 재생성
    ```
    grub2-mkconfig -o /boot/grub2/grub.cfg
    ```

7. 로그 및 오류 메시지 모니터링
    - /var/log/messages, /var/log/secure 등에서 이상 로그 확인
    - journalctl -p err -xb 명령으로 부팅 후 중요 에러 점검    