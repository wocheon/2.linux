# WAS-DB 연동 (Tomcat - MariaDB)

## WAS (Tomcat) 세팅
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
```bash
wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.91/bin/apache-tomcat-8.5.91.tar.gz
tar -zxvf apache-tomcat-8.5.91.tar.gz 
mv apache-tomcat-8.5.91/ tomcat; mv tomcat /usr/local/lib/
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

### Tomcat 동작 확인
- 서비스 기동
```bash
cd /usr/local/lib/tomcat/bin/
./startup.sh
```

- 브라우저에서 정상작동 확인
```bash
curl localhost:8080
```

### Tomcat 서비스 등록 
* /etc/init.d/tomcat 등록
	* $\textcolor{orange}{\textsf{* 해당 방법은 문제가 있으므로 /etc/systemd/system/tomcat.service 추가하는 방식으로 진행 }}$ 
>vi /etc/init.d/tomcat 
```bash
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.372.b07-1.el7_9.x86_64
export CATALINA_HOME=/usr/local/lib/tomcat

case "$1" in
    start)
        echo "Starting tomcat: "
        $CATALINA_HOME/bin/startup.sh
        ;;
    stop)
        echo "Shutting down tomcat: "
        $CATALINA_HOME/bin/shutdown.sh
        ;;
    restart)
        echo "Restarting tomcat: "
        $CATALINA_HOME/bin/shutdown.sh;
        $CATALINA_HOME/bin/startup.sh
        ;;
    *)
        echo "Usage: service tomcat {start|stop|restart}"
        exit 1
esac
exit 0
```
<br>

* 권한 변경
```bash
chmod 775 tomcat
```
<br>

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
<br>

### tomcat 서비스 기동
```bash
systemctl daemon-reload
systemctl enable tomcat --now
```


## DB 설치
 * MariaDB 사용하며 하였으며 mysql로 하면 드라이버 변경 필요.
 
### mariadb 설치
```bash
yum install -y mariadb-server.x86_64
systemctl restart mariadb
mysql_secure_installation
```

### tomcat 데이터 베이스 생성
* MariaDB 접속
```
mysql -u root -pwelcome1
```
<br>

* 데이터베이스 생성 및 권한 설정
```sql
create database tomcat;
grant all privileges on *.* to 'root'@'%' identified by 'welcome1';
flush privileges;
```
<br>

 - 테이블 생성 및 데이터 입력
 ```sql
use tomcat;
create table test (id varchar(20) primary key, pw varchar(20));
INSERT INTO test (id, pw) VALUES ('admin', 'admin123');
SELECT * FROM test;
commit;
```
<br>

## mariadb-java-client 설치
```bash
cd $JAVA_HOME/lib
wget https://dlm.mariadb.com/2896635/Connectors/java/connector-java-2.7.9/mariadb-java-client-2.7.9.jar
cp mariadb-java-client-2.7.9.jar  $CATALINA_HOME/lib/
```
## tomcat 재기동
```bash
systemctl restart tomcat
```


## DB연결 확인

### DB연결 확인용 페이지 작성
[mariadb_contest.jsp](https://github.com/wocheon/2.Linux/blob/main/tomcat/mariadb_contest.jsp)

### DB연결 정상 확인
```bash
curl localhost:8080 
```
```
http://localhost:8080 
```

