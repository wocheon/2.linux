# Ganlia - 서버 모니터링 툴
- 여러 서버를 클러스터 형태로 묶어서 모니터링이 가능
    - 포트 및 여러 클러스터를 원하는대로 지정가능
- gmond 에이전트 설치 필요 
    - Ubuntu > Ganglia-Monitor

- 메트릭 및 그래프 기본제공 

- httpd를 통해 웹 대시보드 제공

## 설치 전 타임존 변경

- ganglia 서버 및 모니터링 대상서버 타임존 일치하게 설정 후 작업진행

```
timedatectl set-timezone Asia/Seoul
```

## Ganglia 서버 설정

- ganglia 설치
```bash
yum update && yum install epel-release
yum install -y ganglia rrdtool ganglia-gmetad ganglia-gmond ganglia-web 

# Ubuntu의 경우 gmond는 ganglia-monitor로 설치
```
### Ganlia web 접근시 계정 설정 
```
htpasswd -c /etc/httpd/auth.basic admin
```
- ganglia.conf 파일에 인증내용 입력
>vi /etc/httpd/conf.d/ganglia.conf
```
Alias /ganglia /usr/share/ganglia
<Location /ganglia>
AuthType basic
AuthName "Ganglia web UI"
AuthBasicProvider file
AuthUserFile "/etc/httpd/auth.basic"
Require user admin
</Location>
```
- 계정 로그인없이 바로 접속하는 경우
```
Alias /ganglia /usr/share/ganglia
<Location /ganglia>
    Order deny,allow
    Allow from all
    Require all granted
</Location>
```

### Gmetad.conf 수정 
- grid명을 변경
- 클러스터 및 클러스터에서 사용할 포트를 명시

>vi /etc/ganglia/gmetad.conf
```bash
gridname "Home office"
data_source "cluster-01" localhost:8649 # Cluster-01
data_source "cluster-02" localhost:8080 # Cluster-02
```

### gmond.conf 수정
- 현재 서버의 메트릭을 보낼 cluster 명과 Ganglia 서버명을 명시

>vi /etc/ganglia/gmond.conf
```bash
cluster {
name = "cluster-01" # The name in the data_source directive in gmetad.conf
owner = "unspecified"
latlong = "unspecified"
url = "unspecified"
}
udp_send_channel {
  #bind_hostname = yes # Highly recommended, soon to be default.
                       # This option tells gmond to use a source address
                       # that resolves to the machine's hostname.  Without
                       # this, the metrics may appear to come from any
                       # interface and the DNS names associated with
                       # those IPs will be used to create the RRDs.
#  mcast_join = 239.2.11.71     해당 라인 주석처리
  host = 192.168.1.46
  port = 8649
  ttl = 1
}

/* You can specify as many udp_recv_channels as you like as well. */
udp_recv_channel {
#  mcast_join = 239.2.11.71 해당 라인 주석처리
  port = 8649
#  bind = 239.2.11.71 해당 라인 주석처리
  retry_bind = true
  # Size of the UDP buffer. If you are handling lots of metrics you really
  # should bump it up to e.g. 10MB or even higher.
  # buffer = 10485760
}
```
### httpd 재시작후 접속 확인
```
systemctl restart httpd gmetad gmond
```
- 웹 브라우저로 접속
    - http://192.168.1.46/ganglia
        - admin/admin


## 모니터링 대상 서버 설정

- gmond agnet 설치
```bash
yum install -y ganglia-gmond
```

### gmond.conf 수정
- 현재 서버의 메트릭을 보낼 cluster 명과 Ganlia 서버명을 명시
>vi /etc/ganglia/gmond.conf
```bash
cluster {
name = "cluster-01" # The name in the data_source directive in gmetad.conf
owner = "unspecified"
latlong = "unspecified"
url = "unspecified"
}
udp_send_channel {
  #bind_hostname = yes # Highly recommended, soon to be default.
                       # This option tells gmond to use a source address
                       # that resolves to the machine's hostname.  Without
                       # this, the metrics may appear to come from any
                       # interface and the DNS names associated with
                       # those IPs will be used to create the RRDs.
#  mcast_join = 239.2.11.71 
  host = 192.168.1.46
  port = 8649
  ttl = 1
}

/* You can specify as many udp_recv_channels as you like as well. */
udp_recv_channel {
#  mcast_join = 239.2.11.71
  port = 8649
#  bind = 239.2.11.71
  retry_bind = true
  # Size of the UDP buffer. If you are handling lots of metrics you really
  # should bump it up to e.g. 10MB or even higher.
  # buffer = 10485760
}
```

- gmond 프로세스 시작
```
systemctl enable gmond --now
```

- 웹 대시보드에 접속 후 정상적으로 올라오는지 확인


### 웹 접속 시 오류 처리
- 다음과 같은 오류 발생시 해결 방법
```bash
There was an error collecting ganglia data (127.0.0.1:8652): fsockopen error: Permission denied 
```

- gmetad 서비스 상태 확인 
```bash
systemctl status gmetad
â— gmetad.service - Ganglia Meta Daemon
   Loaded: loaded (/usr/lib/systemd/system/gmetad.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Thu 2024-02-08 14:14:53 KST; 22s ago
  Process: 2056 ExecStart=/usr/sbin/gmetad -d 1 (code=exited, status=1/FAILURE)
 Main PID: 2056 (code=exited, status=1/FAILURE)

Feb 08 14:14:53 gcp-ansible-test systemd[1]: Started Ganglia Meta Daemon.
Feb 08 14:14:53 gcp-ansible-test gmetad[2056]: Sources are ...
Feb 08 14:14:53 gcp-ansible-test gmetad[2056]: Source: [cluster-01, step 15] has 1 sources
Feb 08 14:14:53 gcp-ansible-test gmetad[2056]: 127.0.0.1
Feb 08 14:14:53 gcp-ansible-test gmetad[2056]: Data thread 140454769583872 is monitoring [cluster-01] data source
Feb 08 14:14:53 gcp-ansible-test gmetad[2056]: 127.0.0.1
Feb 08 14:14:53 gcp-ansible-test gmetad[2056]: Unable to mkdir(/var/lib/ganglia/rrds/cluster-01/gcp-ansible-test.asia-northeast3-c.c.test-project.internal): Permission denied
#! /var/lib/ganglia/rrds/cluster-01에 디렉토리 생성이 불가하여 서비스 기동 불가
Feb 08 14:14:53 gcp-ansible-test systemd[1]: gmetad.service: main process exited, code=exited, status=1/FAILURE
Feb 08 14:14:53 gcp-ansible-test systemd[1]: Unit gmetad.service entered failed state.
Feb 08 14:14:53 gcp-ansible-test systemd[1]: gmetad.service failed.
```


- 해당 디렉토리 권한 확인 
```
ll /var/lib/ganglia/rrds/cluster-01
total 8
drwxr-xr-x. 2 nobody nobody 4096 Feb  8 11:27 gcp-ansible-test
drwxr-xr-x. 2 nobody nobody 4096 Feb  8 11:27 __SummaryInfo__
```
- 권한 재설정 및 프로세스 재시작
```bash
$ chown -R ganglia:ganglia /var/lib/ganglia
$ systemctl restart gmetad
$ systemctl status gmetad
gmetad.service - Ganglia Meta Daemon
   Loaded: loaded (/usr/lib/systemd/system/gmetad.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2024-02-08 14:16:12 KST; 1s ago
 Main PID: 2080 (gmetad)
   CGroup: /system.slice/gmetad.service
           â””â”€2080 /usr/sbin/gmetad -d 1

Feb 08 14:16:12 gcp-ansible-test systemd[1]: Started Ganglia Meta Daemon.
Feb 08 14:16:12 gcp-ansible-test gmetad[2080]: Sources are ...
Feb 08 14:16:12 gcp-ansible-test gmetad[2080]: Source: [cluster-01, step 15] has 1 sources
Feb 08 14:16:12 gcp-ansible-test gmetad[2080]: 127.0.0.1
Feb 08 14:16:12 gcp-ansible-test gmetad[2080]: Data thread 140076934088448 is monitoring [cluster-01] data source
Feb 08 14:16:12 gcp-ansible-test gmetad[2080]: 127.0.0.1
# 정상 기동확인
```
