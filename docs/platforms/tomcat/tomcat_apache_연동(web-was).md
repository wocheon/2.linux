# Apache-Tomcat 연동 (web-was)

## 기본세팅
* OS : centos7
* selinux, firewalld disabled
* vpc 방화벽 80,443,8080 open
* web ip : 192.168.1.100
* was ip : 192.168.2.200
* JDK Version : 1.8.0
* Tomcat Version : 8.5.91
 
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

## WEB (Apache) 세팅

### Apache 설치
```bash
yum install -y httpd
```

### Apache 서비스 기동
```bash
systemctl enable httpd --now
```

### VirtualHost 설정
>vi /etc/httpd/conf/httpd.conf 

```bash
     56 Include conf.modules.d/*.conf
     57 LoadModule proxy_module modules/mod_proxy.so
     58 LoadModule proxy_connect_module modules/mod_proxy_connect.so
     59 LoadModule proxy_http_module modules/mod_proxy_http.so

<VirtualHost *:80>
       ServerName localhost
       ProxyRequests Off
       ProxyPreserveHost On
       <Proxy *>
                Order deny,allow
                Allow from all
        </Proxy>
        ProxyPass / http://192.168.2.200:8080/
		ProxyPassReverse / http://192.168.2.200:8080/
</VirtualHost>
```
<br>


## Reverse Proxy 로 부하분산

>vi /etc/httpd/conf/httpd.conf
```bash
<VirtualHost *:80>
  ServerName shop.playon.tistory.com
  ProxyRequests Off
  ProxyPreserveHost On
  <Location /user>
    ProxyPass http://user.playon.tistory.com/
    ProxyPassReverse http://user.playon.tistory.com/
  </Location>
  <Location /order>
    ProxyPass http://order.playon.tistory.com/
    ProxyPassReverse http://order.playon.tistory.com/
  </Location>
</VirtualHost>
```
<br>
