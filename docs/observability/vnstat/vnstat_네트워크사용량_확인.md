# VNSTAT - 네트워크 사용량 확인용

- 자원소모가 거의 없이 네트워크사용량을 확인할수 있는 패키지
- 자체적으로 sqlite DB를 생성하여 네트워크 사용량을 기록
- 일별, 월별, 그래프등 다양한 형태로 사용량 확인가능
- 수동으로 업데이트가 필요하므로 주로 Crontab에 등록하여 사용

## 설치 
- vnstat 패키지 설치
    - yum이나 apt등의 패키지 매니저를 통해 vnstat패키지 설치

```
yum install -y vnstat 

or 

apt-get install -y vnstat
```

## 업데이트 및 확인
- 네트워크 사용량을 확인할 인터페이스 확인
```bash
$ ip ad
ip ad
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc mq state UP group default qlen 1000
    link/ether 42:01:c0:a8:01:15 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.21/32 brd 192.168.1.21 scope global noprefixroute dynamic eth0
       valid_lft 2694sec preferred_lft 2694sec
    inet6 fe80::319c:2324:74c4:2764/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

- 기록 대상 인터페이스를 지정 및 기록 업데이트
```bash
$ vnstat -u -i eth0
Error: Unable to read database "/var/lib/vnstat/eth0": No such file or directory
Info: -> A new database has been created. # 기존 기록이 없어서 새로 데이터베이스가 생성됨
# 데이터베이스 생성 후 다시 업데이트 진행
$ vnstat -u -i eth0
```

- 일별 사용량 확인
```bash
$vnstat -d

 eth0  /  daily

         day         rx      |     tx      |    total    |   avg. rate
     ------------------------+-------------+-------------+---------------
     02/07/2024       13 KiB |       5 KiB |      18 KiB |    0.00 kbit/s
     ------------------------+-------------+-------------+---------------
     estimated        --     |      --     |      --     |


```

- 기타 옵션
```bash
$ vnstat --help
 vnStat 1.15 by Teemu Toivola <tst at iki dot fi>

         -q,  --query          query database
         -h,  --hours          show hours
         -d,  --days           show days
         -m,  --months         show months
         -w,  --weeks          show weeks
         -t,  --top10          show top 10 days
         -s,  --short          use short output
         -u,  --update         update database
         -i,  --iface          select interface (default: eth0)
         -?,  --help           short help
         -v,  --version        show version
         -tr, --traffic        calculate traffic
         -ru, --rateunit       swap configured rate unit
         -l,  --live           show transfer rate in real time

See also "--longhelp" for complete options list and "man vnstat".
```

- 자동으로 업데이트 되도록 crontab에 등록 
```
*/5 * * * * /usr/bin/vnstat -u -i eth0
```

## 기존 내역 삭제 방법

```bash
$ vnstat --delete -i eth0 --force
Database for interface "eth0" deleted.
The interface will no longer be monitored. Use --create
if monitoring the interface is again needed.
```