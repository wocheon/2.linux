# Scouter (APM) 설치 

## 기본 구성 
1. Scouter (192.168.1.101) 
    - Scouter Server 용
2. WAS-1 (192.168.1.102) 
    - Tomcat 및 Scouter Host 구성 
3. WAS-2 (192.168.1.103) 
    - Tomcat 및 Scouter Host 구성 


## WAS (Tomcat) 세팅 - (WAS-1, WAS-2)
### JDK 설치
* 패키지 설치
```bash
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
readlink -f /usr/bin/java
```

* 환경변수 세팅
>vi /etc/profile
```bash
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.372.b07-1.el7_9.x86_64
PATH=$PATH:$JAVA_HOME/bin
CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
```

### Tomcat설치

* 패키지 설치
    - 설치시 버전 확인 후 진행 
```bash
wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.100/bin/apache-tomcat-8.5.100.tar.gz
tar -zxvf apache-tomcat-8.5.100.tar.gz 
mv apache-tomcat-8.5.100/ /usr/local/lib/tomcat
```

* 환경변수 세팅
>vi /etc/profile
```bash
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.372.b07-1.el7_9.x86_64
JRE_HOME=$JAVA_HOME/jre

CATALINA_HOME=/usr/local/lib/tomcat
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$CATALINA_HOME/bin
CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$CATALINA_HOME/lib/jsp-api.jar:$CATALINA_HOME/lib/servlet-api.jar

export JAVA_HOME
export JRE_HOME
export CLASSPATH CATALINA_HOME
```
<br>

* 환경변수 재설정
```bash
source /etc/profile
```

### Tomcat 서비스 등록 
* /etc/systemd/system/tomcat.service 등록
>vi /etc/systemd/system/tomcat.service
```bash
[Unit]
Description=tomcat
After=network.target syslog.target

[Service]
Type=forking
Environment=/usr/local/lib/tomcat
User=root
Group=root
ExecStart=/usr/local/lib/tomcat/bin/startup.sh
ExecStop=/usr/local/lib/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
```
- tomcat 서비스 기동 
```
systemctl restart tomcat 
```

- 접속 확인 
```
curl localhost:8080
```

<br>



## Scouter 설치 - (전체)

- 공식 Github에서 파일 다운로드 
    - https://github.com/scouter-project/scouter/releases

```
wget https://github.com/scouter-project/scouter/releases/download/v2.20.0/scouter-all-2.20.0.tar.gz
tar xvf scouter-all-2.20.0.tar.gz
```


## Scouter 서버 실행 - (Scouter)

- Scouter-Server 실행 
```
sh /root/scouter/server/startup.sh
```
- 정상 실행시 디렉토리에 {pid}.scouter 파일 생성됨
    - 파일 삭제시 프로세스 종료됨 

## Scouter host agent 설정 - (WAS-1, WAS-2)
- Scouter-hostAgent 설정 변경 
> vi scouter/agent.host/conf/scouter.conf  
```sh
### scouter host configruation sample
net_collector_ip=192.168.1.101
net_collector_udp_port=6100
net_collector_tcp_port=6100
#cpu_warning_pct=80
#cpu_fatal_pct=85
#cpu_check_period_ms=60000
#cpu_fatal_history=3
#cpu_alert_interval_ms=300000
#disk_warning_pct=88
#disk_fatal_pct=92
```

- Scouter Host-Agent 실행 
```
sh /root/scouter/agent.host/host.sh
```
- 정상 실행시 디렉토리에 {pid}.scouter 파일 생성됨
    - 파일 삭제시 프로세스 종료됨 


## Scouter java agent 설정 - (WAS-1, WAS-2)

- Scouter-javaAgent 설정 변경 
    - Tomcat과 연결을 위해 JavaAgent 설정을 변경 

> vi scouter/agent.java/conf/scouter.conf  
```sh
### scouter java agent configuration sample
obj_name=WAS-01
net_collector_ip=192.168.1.101
net_collector_udp_port=6100
net_collector_tcp_port=6100
# webapp topology 구성 허용 
counter_interaction_enabled=true
```

- Tomcat 환경변수 변경 
    - setenv.sh 파일을 생성하여 환경변수 입력 
    - 해당 파일을 catalina.sh 자동으로 읽어서 반영됨

> vi $CATALINA_HOME/bin/setenv.sh
```sh
#!/bin/sh

#Scouter Setting 
SCOUTER_AGENT_DIR="/root/scouter/agent.java"
CATALINA_OPTS=" ${CATALINA_OPTS} -javaagent:${SCOUTER_AGENT_DIR}/scouter.agent.jar"
CATALINA_OPTS=" ${CATALINA_OPTS} -Dscouter.config=${SCOUTER_AGENT_DIR}/conf/scouter.conf"
CATALINA_OPTS=" ${CATALINA_OPTS} -Dobj_name=8080"

# Timezone setting
CATALINA_OPTS=" ${CATALINA_OPTS} -Duser.timezone=GMT+09:00 -Dfile.encoding=UTF8"
```

- Tomcat 재기동 
```
systemctl restart tomcat 
```

- 정상 작동 확인 
    - Tomcat에 Scouter 설정이 반영됨
```sh
$ ps -ef | grep scouter | grep -v grep
root      2628     1  0 05:34 ?        00:00:20 java -classpath ./scouter.host.jar scouter.boot.Boot ./lib
root      3912     1  1 06:11 ?        00:00:25 /usr/bin/java -Djava.util.logging.config.file=/usr/local/lib/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -javaagent:/root/scouter/agent.java/scouter.agent.jar -Dscouter.config=/root/scouter/agent.java/conf/scouter.conf -Dobj_name=8080 -Dignore.endorsed.dirs= -classpath /usr/local/lib/tomcat/bin/bootstrap.jar:/usr/local/lib/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/lib/tomcat -Dcatalina.home=/usr/local/lib/tomcat -Djava.io.tmpdir=/usr/local/lib/tomcat/temp org.apache.catalina.startup.Bootstrap start
```


## Scouter Client(viewer) 설치 - Windows
- Scouter 서버와 연결가능한 Windows 서버에서 Client 설치 진행
- Scouter Client 실행 시 JDK 설치 필요 (JDK 11이상)

### Windwos JDK11 설치   
- JDK 설치   
    - https://www.openlogic.com/openjdk-downloads
    - zip파일 다운로드 후 원하는 위치로 복사
        - ex) C:\Program Files\jdk-11

- 시스템 환경 변수 편집
    - JAVA_HOME
        - C:\Program Files\jdk-11
    - PATH 
        - %JAVA_HOME%\bin


### Scouter Client(viewer) 설치 
- 공식 깃허브에서 Client 다운로드
    - https://github.com/scouter-project/scouter/releases
	    - scouter.client.product-win32.win32.x86_64.zip

- 압축해제 후 scouter.exe 실행 
    - Server Address 
        - {접속IP}:6100
    - ID/PW 
        - admin/admin