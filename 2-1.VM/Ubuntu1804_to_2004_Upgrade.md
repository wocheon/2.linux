# Ubuntu 18.04 LTS to 20.04 LTS Upgrade
## 개요 
- GCP에서 Ubuntu 18.04 LTS VM을 Ubuntu 20.04 LTS로 업그레이드 진행 
- **업그레이드 전, 항상 백업을 수행할것 (Disk 스냅샷 등)**

---

## **1. 사전 준비**
* 기존 VM 백업을 위해 디스크 스냅샷 작성
```bash
gcloud compute disks snapshot [DISK_NAME] --snapshot-names=[SNAPSHOT_NAME]
```

1. **현재 상태 점검**
   - Ubuntu 18.04가 최신 상태로 업데이트되었는지 확인합니다.
     ```bash
     sudo apt update && sudo apt upgrade -y
     sudo apt autoremove -y
     ```

2. **패키지 매니저 업데이트**
   - 시스템에서 사용 중인 패키지가 최신 상태인지 확인합니다.
     ```bash
     sudo apt install --install-recommends update-manager-core
     ```

3. **재부팅**
   - 업데이트가 적용되도록 VM을 재부팅합니다.
     ```bash
     sudo reboot
     ```

---

## **2. 업그레이드 수행**
1. **업그레이드 명령 실행**
   - `do-release-upgrade` 명령어를 사용하여 Ubuntu 20.04로 업그레이드합니다.
   - 
     ```bash
     sudo do-release-upgrade
     ```
   - 업그레이드가 시작되면 시스템이 자동으로 변경 사항을 분석하고, 필요한 패키지를 다운로드 및 설치합니다.

2. **프롬프트 확인**
   - 업그레이드 과정 중 몇 가지 질문에 대해 확인을 요구할 수 있습니다. 일반적으로 **기본 옵션**을 선택하거나, 기존 구성을 유지하는 것을 추천합니다.
   - 예를 들어:
     - **"Configuration file changes"**: "Keep the local version currently installed" 선택.

3. **업그레이드 완료 후 재부팅**
   - 업그레이드가 완료되면 시스템을 재부팅합니다.
     ```bash
     sudo reboot
     ```

---

## **3. 업그레이드 후 확인**
1. **Ubuntu 버전 확인**
   - 업그레이드가 제대로 되었는지 확인합니다.
     ```bash
     lsb_release -a
     ```
   - 출력이 아래와 비슷해야 합니다:
     ```
     Distributor ID: Ubuntu
     Description:    Ubuntu 20.04.6 LTS
     Release:        20.04
     Codename:       focal
     ```

2. **시스템 및 서비스 점검**
   - 주요 서비스가 정상적으로 작동하는지 확인합니다.
     ```bash
     systemctl status [서비스명]
     ```

3. **잔여 패키지 정리**
   - 더 이상 필요하지 않은 패키지를 정리합니다.
     ```bash
     sudo apt autoremove -y
     ```

