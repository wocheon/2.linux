# GCP 디스크 용량 증설 및 신규 추가


- 신규 디스크 추가
    - 다른용도로 사용할 신규 디스크가 필요한 경우
    - 리눅스 서버의 경우 신규 추가후 파티션 설정/포맷/마운트 작업 필요
    - 윈도우 서버의 경우 디스크 관리에서 포맷 후 할당을 진행

- 기존 디스크 사이즈 증설
    - 부팅 디스크 혹은 추가디스크의 용량 부족 등의 이유로 사이즈 증설이 필요한경우
    - 리눅스 서버의 경우 growpart 패키지 필요
    - 윈도우 서버의 경우 윈도우 내의 디스크관리에서 증설가능


## 신규 디스크 추가
### GCP 콘솔에서 신규 디스크 추가 
- 신규로 디스크를 추가할 서버 상세정보 > 수정 > 추가 디스크 - 새 디스크 추가

- 용도에 따라 기존디스크를 연결 혹은 신규 디스크 생성하여 추가 


## 윈도우 서버 신규 디스크 연결
- 추가 완료 후 RDP로 접속
- 디스크 관리에서 신규 디스크 추가되었는지 확인
- 포맷 후 드라이브 문자 할당하여 사용

## 리눅스 서버 신규 디스크 연결
1. ssh 접속후 lsblk로 디스크 추가 확인
```
[root@domaintest-01 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   25G  0 disk 
├─sda1   8:1    0  200M  0 part /boot/efi
└─sda2   8:2    0 24.8G  0 part /
sdb      8:16   0  100G  0 disk 
```

2. fdisk로 신규디스크 파티션 설정
```
[root@domaintest-01 ~]# fdisk /dev/sdb 
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x67de4478.

The device presents a logical sector size that is smaller than
the physical sector size. Aligning to a physical sector (or optimal
I/O) size boundary is recommended, or performance may be impacted.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-209715199, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-209715199, default 209715199): 
Using default value 209715199
Partition 1 of type Linux and of size 100 GiB is set

Command (m for help): p

Disk /dev/sdb: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: dos
Disk identifier: 0x67de4478

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048   209715199   104856576   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

3. 사용할 디스크 포맷에 따라 파티션 포맷 진행

|포맷|명령어|
|:-|:-|
|ext4|mkfs.ext4|
|xfs|mkfs.xfs|
|btrfs|mkfs.btrfs|

- ext4 포맷 사용
```
[root@domaintest-01 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   25G  0 disk 
├─sda1   8:1    0  200M  0 part /boot/efi
└─sda2   8:2    0 24.8G  0 part /
sdb      8:16   0  100G  0 disk 
└─sdb1   8:17   0  100G  0 part 
[root@domaintest-01 ~]# mkfs.ext4 /dev/sdb1 
mke2fs 1.42.9 (28-Dec-2013)
Discarding device blocks: done                            
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
6553600 inodes, 26214144 blocks
1310707 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2174746624
800 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done   
```

4. 디스크 마운트할 디렉토리 생성
- 기존 디렉토리에 마운트시 생성 x 
```
[root@domaintest-01 ~]# mkdir /data002
```

5. mount 진행 후 확인
```
[root@domaintest-01 ~]# mount /dev/sdb1 /data002
[root@domaintest-01 ~]# df -Th
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  486M     0  486M   0% /dev
tmpfs          tmpfs     494M     0  494M   0% /dev/shm
tmpfs          tmpfs     494M  6.7M  488M   2% /run
tmpfs          tmpfs     494M     0  494M   0% /sys/fs/cgroup
/dev/sda2      xfs        25G  3.5G   22G  14% /
/dev/sda1      vfat      200M   12M  189M   6% /boot/efi
tmpfs          tmpfs      99M     0   99M   0% /run/user/1001
tmpfs          tmpfs      99M     0   99M   0% /run/user/0
/dev/sdb1      ext4       99G   61M   94G   1% /data002
```

- 필요시 /etc/fstab에 추가

```
[파일_시스템_장치]  [마운트_포인트]  [파일_시스템_종류] [옵션] [덤프] [파일체크_옵션]
예) /dev/sdb1  /data002   ext4   defaults   1   1
```

## 기존 디스크 사이즈 증설

### GCP 콘솔에서 디스크 사이즈 증설
- 증설 진행할 디스크 > 수정 > 원하는 만큼 사이즈 증설
    - 디스크 사이즈의 경우 증설은 자유롭게 가능하나 한번 증설된 디스크 사이즈는 다시 줄이는것은 불가능.
    - 증설해야 하는 용량을 확인 후 진행할것.

### 윈도우 서버 디스크 사이즈 증설

- 콘솔에서 디스크 사이즈 증설 후 rdp로 접속 
    - 디스크 관리에서 해당 디스크에 빈 공간이 추가되었는지 확인
    - 기존 사용중인 파티션에서 볼륨 확장을 통해 추가된 사이즈만큼 확장 진행

## 리눅스 서버 디스크 사이즈 증설 

1. SSH 로 서버 접속후 현재 디스크 상태 및 포맷확인
```
[root@domaintest-01 ~]# df -Th
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  486M     0  486M   0% /dev
tmpfs          tmpfs     494M     0  494M   0% /dev/shm
tmpfs          tmpfs     494M  6.7M  488M   2% /run
tmpfs          tmpfs     494M     0  494M   0% /sys/fs/cgroup
/dev/sda2      xfs        25G  3.5G   22G  14% /
/dev/sda1      vfat      200M   12M  189M   6% /boot/efi
tmpfs          tmpfs      99M     0   99M   0% /run/user/1001
/dev/sdb1      ext4      9.8G   37M  9.2G   1% /data001
```

2. lsblk 및 partprobe로 디스크 추가증설 용량 확인
```
[root@domaintest-01 ~]# partprobe /dev/sdb

[root@domaintest-01 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   25G  0 disk 
├─sda1   8:1    0  200M  0 part /boot/efi
└─sda2   8:2    0 24.8G  0 part /
sdb      8:16   0   15G  0 disk 
└─sdb1   8:17   0   10G  0 part /data001
```

3. growpart 설치 
```
yum -y install cloud-utils-growpart
```

4. growpart로 기존 디스크에 추가 공간 할당
```
[root@domaintest-01 ~]# growpart /dev/sdb 1
CHANGED: partition=1 start=2048 old: size=20969472 end=20971520 new: size=31455199 end=31457247
```

5. 디스크 포맷에 따라 파티션 확장 진행

|포맷|명령어|
|:-|:-|
|ext4|resize2fs /dev/sda1|
|xfs| xfs_growfs -d /|
|btrfs|btrfs filesystem resize max /|


- ext4 포맷이므로 resize2fs 사용
```
[root@domaintest-01 ~]# resize2fs /dev/sdb1
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/sdb1 is mounted on /data001; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 2
The filesystem on /dev/sdb1 is now 3931899 blocks long.
```

6. 디스크 확장 결과 확인
```
[root@domaintest-01 ~]# df -Th
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  486M     0  486M   0% /dev
tmpfs          tmpfs     494M     0  494M   0% /dev/shm
tmpfs          tmpfs     494M  6.7M  488M   2% /run
tmpfs          tmpfs     494M     0  494M   0% /sys/fs/cgroup
/dev/sda2      xfs        25G  3.5G   22G  14% /
/dev/sda1      vfat      200M   12M  189M   6% /boot/efi
tmpfs          tmpfs      99M     0   99M   0% /run/user/1001
/dev/sdb1      ext4       15G   41M   14G   1% /data001
```


### MBR to GPT 로 변환 후 사이즈 증설하기 (2TB이상 디스크 증설 시)
- 2TB이상 디스크를 증설하는 경우 파티션 유형이 MBR로 되어있는지 확인이 필요함
    - MBR 파티션의 경우 최대 크기가 2TB로 제한되기 때문

- MBR 파티션의 크기를 2TB이상으로 올려야한다면 gpt파티션으로 변경하는 작업이 필요

#### 작업순서
- 순서대로 진행하지않으면 파티션이 깨질수도있으니 반드시 순서대로 진행

1. 파티션 유형 확인
2. gdisk 설치 확인
3. 디스크 스냅샷 작성
4. 디스크 여유공간 확보
5. gdisk로 파티션 유형을 변경 (MBR to GPT)
6. growpart로 기존 디스크에 추가 공간 할당
7. 디스크 포맷에 따라 파티션 확장 진행


- `1. 파티션 유형 확인`
```bash
[root@gcp-ansible-test ~]$ parted -l

Model: Google PersistentDisk (scsi)
Disk /dev/sdb: 10.7GB
Sector size (logical/physical): 512B/4096B
Partition Table: msdos #msdos = MBR 파티션
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  10.7GB  10.7GB  primary  ext4
```

- `2. gdisk 설치확인`
    - gcp vm에는 기본설치됨
```
[root@gcp-ansible-test ~]$ rpm -qa | grep gdisk
gdisk-0.8.10-3.el7.x86_64
```

- `3. 디스크 스냅샷 작성` 
    - 디스크 파티션 유형변경 시 문제가 발생하면 마운트가 불가하거나 파일이 꺠지는 불상사가 발생할 수 있으므로 작업 시작전 항상 디스크 스냅샷을 작성 후 진행할 것

- `4. 디스크 용량 증설`
    - 추가로 증설할 사이즈만큼 디스크를 증설

    - 증설 후 바로 늘리지 말것 
        
        - MBR 파티션은 시작부분만을 사용하여 파티션 테이블을 사용하나 <br> GPT파티션은 양쪽끝을 모두 사용함
        
        - 따라서 마지막 파티션을 최소 33블록 이상 줄여야 변환이 가능
            - 512바이트 블록으로 가정하면 16,896 바이트

        - 한마디로 디스크에 추가공간이 없다면 MBR to GPT는 불가능

- `* 파티션 공간 부족시 발생에러`
```
gdisk /dev/sdb
GPT fdisk (gdisk) version 0.8.10

Partition table scan:
  MBR: MBR only
  BSD: not present
  APM: not present
  GPT: not present


***************************************************************
Found invalid GPT and valid MBR; converting MBR to GPT format
in memory. THIS OPERATION IS POTENTIALLY DESTRUCTIVE! Exit by
typing 'q' if you don't want to convert your MBR partitions
to GPT format!
***************************************************************


Warning! Secondary partition table overlaps the last partition by
33 blocks!
You will need to delete this partition or resize it in another utility.
```

- `5. gdisk로 파티션 유형을 변경 (MBR to GPT)`

- gdisk 실행후 파티션 유형 변경
```
[root@gcp-ansible-test ~]# gdisk /dev/sdb
GPT fdisk (gdisk) version 0.8.10

Partition table scan:
  MBR: MBR only
  BSD: not present
  APM: not present
  GPT: not present


***************************************************************
Found invalid GPT and valid MBR; converting MBR to GPT format
in memory. THIS OPERATION IS POTENTIALLY DESTRUCTIVE! Exit by
typing 'q' if you don't want to convert your MBR partitions
to GPT format!
***************************************************************


Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): Y
OK; writing new GUID partition table (GPT) to /dev/sdb.
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot.
The operation has completed successfully.
```


- 파티션 유형 변경 확인
```bash
[root@gcp-ansible-test ~]$ parted -l
Model: Google PersistentDisk (scsi)
Disk /dev/sdb: 10.7GB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt # GPT로 변경됨
Disk Flags:

Number  Start   End     Size    File system  Name              Flags
 1      1049kB  10.7GB  10.7GB  ext4         Linux filesystem
```



6. growpart로 기존 디스크에 추가 공간 할당

```
[root@gcp-ansible-test ~]# growpart /dev/sdb 1
CHANGED: partition=1 start=2048 old: size=16777216 end=16779264 new: size=20969438 end=20971486
```

7. 디스크 포맷에 따라 파티션 확장 진행
```
[root@gcp-ansible-test ~]# resize2fs /dev/sdb1
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/sdb1 is mounted on /data001; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/sdb1 is now 2621179 blocks long.
```

- 결과 확인

```
[root@gcp-ansible-test ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   24G  0 disk
├─sda1   8:1    0  200M  0 part /boot/efi
└─sda2   8:2    0 23.8G  0 part /
sdb      8:16   0   10G  0 disk
└─sdb1   8:17   0   10G  0 part /data001
[root@gcp-ansible-test ~]# df -Th
Filesystem                      Type          Size  Used Avail Use% Mounted on
devtmpfs                        devtmpfs      1.9G     0  1.9G   0% /dev
tmpfs                           tmpfs         1.9G     0  1.9G   0% /dev/shm
tmpfs                           tmpfs         1.9G  8.5M  1.9G   1% /run
tmpfs                           tmpfs         1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/sda2                       xfs            24G  9.6G   15G  40% /
/dev/sda1                       vfat          200M   12M  189M   6% /boot/efi
gcp-in-ca-test-bucket-wocheon07 fuse.gcsfuse  1.0P     0  1.0P   0% /share
tmpfs                           tmpfs         379M     0  379M   0% /run/user/1001
/dev/sdb1                       ext4          9.8G   36M  9.2G   1% /data001
```