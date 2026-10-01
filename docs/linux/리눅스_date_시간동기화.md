# 리눅스 date 시간동기화 방법

## 네트워크 서버와 시간 동기화
```bash
yum install rdate
rdate -s time.bora.net
date
```
<br>

## 타임존 변경

* Seoul 타임존 조회
```bash
[root@haproxy testdomainnames2.com]# timedatectl list-timezones | grep Seoul
Asia/Seoul
```
<br>

* Seoul 타임존으로 변경
```bash
[root@haproxy testdomainnames2.com]# timedatectl set-timezone Asia/Seoul
[root@haproxy testdomainnames2.com]# timedatectl
      Local time: Wed 2023-07-19 13:07:32 KST
  Universal time: Wed 2023-07-19 04:07:32 UTC
        RTC time: Wed 2023-07-19 04:07:33
       Time zone: Asia/Seoul (KST, +0900)
     NTP enabled: yes
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a
```
