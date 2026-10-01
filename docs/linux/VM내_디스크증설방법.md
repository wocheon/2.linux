## VM 디스크 증설 방법 

### 0. 디스크 크기 인식 확인 (필요 시 rescan)
- VM에 할당된 디스크 용량을 늘린 후, VM 내부에서 변경된 디스크 크기를 인식시키고 파일 시스템을 확장하는 과정입니다.

### 1. VM 디스크 증설 (클라우드 콘솔 또는 하이퍼바이저에서)
- 클라우드 공급자(AWS, GCP, Azure 등) 또는 하이퍼바이저(VMware, VirtualBox 등) 콘솔에서 VM의 디스크 크기를 원하는 만큼 늘립니다.
- **주의**: 이 단계는 VM 외부에서 진행됩니다.

### 2. VM 내부에서 디스크 변경 사항 확인
- VM에 SSH 등으로 접속하여 디스크 변경 사항을 확인합니다.
```bash
lsblk
```
- `lsblk` 명령을 실행하여 디스크 목록을 확인합니다. 여기서 늘어난 디스크의 크기가 반영되었는지 확인합니다.
- 만약 변경된 크기가 즉시 반영되지 않는다면, 다음 명령으로 디스크를 재스캔할 수 있습니다.
```bash
# SCSI 디스크의 경우 (대부분의 클라우드 VM)
echo 1 > /sys/class/scsi_disk/host*/device*/rescan
# 또는 특정 디스크만 재스캔 (예: sda)
echo 1 > /sys/block/sda/device/rescan
```
- 재스캔 후 다시 `lsblk`를 실행하여 디스크 크기가 올바르게 반영되었는지 확인합니다.

### 3. 파티션 확장
- 디스크 크기가 늘어났다면, 해당 디스크의 파티션을 확장해야 합니다.
- **주의**: 기존 파티션이 없는 경우 새로 생성해야 하며, 기존 파티션이 있는 경우 확장해야 합니다.
- `fdisk` 또는 `parted`를 사용하여 파티션을 확장합니다. 대부분의 경우 `growpart` 유틸리티를 사용하는 것이 가장 안전하고 쉽습니다.

#### 3-1. `growpart` 설치 (필요시)
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install cloud-guest-utils

# CentOS/RHEL
sudo yum install cloud-utils-growpart
```

#### 3-2. 파티션 확장
- 예를 들어 `/dev/sda` 디스크의 첫 번째 파티션(`/dev/sda1`)을 확장하는 경우:
```bash
sudo growpart /dev/sda 1
```
- `growpart` 명령은 파티션 테이블을 업데이트하여 파티션의 크기를 디스크의 남은 공간만큼 확장합니다.
- **주의**: `/dev/sda`는 디스크 이름이고, `1`은 해당 디스크의 파티션 번호입니다. `lsblk` 명령으로 정확한 디스크와 파티션 정보를 확인해야 합니다.

### 4. 파일 시스템 확장
- 파티션이 확장되었으면, 이제 해당 파티션의 파일 시스템을 확장해야 합니다.
- 파일 시스템 종류에 따라 명령어가 다릅니다. `df -hT` 또는 `lsblk -f` 명령으로 파일 시스템 종류를 확인할 수 있습니다.

#### 4-1. ext4 파일 시스템 확장
```bash
sudo resize2fs /dev/sda1
```
- `resize2fs` 명령은 ext2, ext3, ext4 파일 시스템을 확장하는 데 사용됩니다.

#### 4-2. xfs 파일 시스템 확장
```bash
sudo xfs_growfs /mount/point # 마운트 포인트를 지정
# 또는
sudo xfs_growfs /dev/sda1 # 디바이스를 직접 지정 (마운트된 상태여야 함)
```
- `xfs_growfs` 명령은 XFS 파일 시스템을 확장하는 데 사용됩니다. 일반적으로 마운트 포인트를 지정하는 것이 권장됩니다.

### 5. 최종 확인
- `df -hT` 명령을 사용하여 파일 시스템의 크기가 올바르게 확장되었는지 확인합니다.
```bash
df -hT
```
- 이제 VM 내에서 디스크 공간이 증설된 것을 확인할 수 있습니다.


---

## LVM 증설 방법 


### 1. 디스크 크기 인식 확인 (필요 시 rescan)
- VM에 할당된 디스크 용량을 늘린 후, VM 내부에서 변경된 디스크 크기를 인식시키고 LVM(Logical Volume Manager)을 확장하는 과정입니다.
- `lsblk` 명령을 실행하여 디스크 목록을 확인하고, 늘어난 디스크의 크기가 반영되었는지 확인합니다.
```bash
lsblk
```
- 만약 변경된 크기가 즉시 반영되지 않는다면, 위에서 설명한 `echo 1 > /sys/class/scsi_disk/host*/device*/rescan` 또는 `echo 1 > /sys/block/sda/device/rescan` 명령으로 디스크를 재스캔할 수 있습니다.

### 2. 물리 파티션 확장
- `growpart` 유틸리티를 사용하여 물리 디스크의 파티션을 확장합니다.
- 예를 들어 `/dev/sdb` 디스크의 첫 번째 파티션(`/dev/sdb1`)을 확장하는 경우:
```bash
sudo growpart /dev/sdb 1
```
- **주의**: `/dev/sdb`는 디스크 이름이고, `1`은 해당 디스크의 파티션 번호입니다. `lsblk` 명령으로 정확한 디스크와 파티션 정보를 확인해야 합니다.

### 3. LVM 물리 볼륨 사이즈 갱신
- 확장된 물리 파티션의 크기를 LVM 물리 볼륨(Physical Volume, PV)에 반영합니다.
```bash
sudo pvresize /dev/sdb1
```

### 4. 논리 볼륨 확인
- 현재 시스템에 구성된 논리 볼륨(Logical Volume, LV)들의 정보를 확인합니다.
```bash
lvdisplay
```

### 5. 논리 볼륨 확장 (+ 파일시스템 자동 확장 옵션 -r 사용 권장)
- 논리 볼륨을 확장하고, `-r` 옵션을 사용하여 파일 시스템까지 자동으로 확장합니다.
- `+100%FREE`는 해당 볼륨 그룹(Volume Group, VG) 내의 모든 사용 가능한 여유 공간을 논리 볼륨에 할당하라는 의미입니다.
- `-r` 옵션을 사용하면 `resize2fs` (ext4) 또는 `xfs_growfs` (xfs) 명령을 별도로 실행할 필요가 없습니다.
- 예를 들어 `myvg` 볼륨 그룹의 `mylv` 논리 볼륨을 확장하는 경우:
```bash
sudo lvextend -r -l +100%FREE /dev/mapper/myvg-mylv
```
- **주의**: `/dev/mapper/myvg-mylv`는 논리 볼륨의 경로입니다. `lvdisplay` 명령으로 정확한 경로를 확인해야 합니다.

### 6. 최종 확인
- `df -hT` 명령을 사용하여 파일 시스템의 크기가 올바르게 확장되었는지 확인합니다.
```bash
df -hT
```
- 이제 VM 내에서 LVM을 통해 디스크 공간이 증설된 것을 확인할 수 있습니다.
