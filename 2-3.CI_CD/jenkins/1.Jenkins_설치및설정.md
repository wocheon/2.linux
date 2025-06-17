# Jenkins - Jenkins 설치 및 기본설정

## Jenkins 설치 진행
### 종속 패키지 설치
```bash
yum install -y wget maven git docker
```
$\textcolor{orange}{\textsf{* Maven 설치 시, JDK가 같이 설치되나 버전 문제로 인해 JDK 11로 변경 필요.}}$ 

### jdk 버전 변경
```bash
yum install -y java-11-openjdk-devel.x86_64
update-alternatives --config java
```
- `JDK 버전을 11로 변경`

### 환경변수 설정
```bash
$ which java
/bin/java
```
<br>

```
$ readlink -f /bin/java
/usr/lib/jvm/java-11-openjdk-11.0.19.0.7-1.el7_9.x86_64/bin/java
```
<br>

>vi /etc/profile
```bash
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.19.0.7-1.el7_9.x86_64
PATH=$PATH:$JAVA_HOME/bin
CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
```
<br>

### 환경변수 재설정
```bash
source /etc/profile 
```
$\textcolor{orange}{\textsf{* JDK는 Slave NODE에도 설치. (추후 작업전 세팅을 위함)}}$ 

<br>


## Jenkins 설치

### Jenkins Repository 설치
```bash
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```

### Jenkins Package 설치
```bash
yum install -y jenkins
systemctl enable jenkins --now
systemctl status jenkins
```
$\textcolor{orange}{\textsf{*오류나면 jenkins -version 등으로 확인해보기..}}$ 


### Jenkins 접속 확인
- URL 
	- http://localhost:8080

- Jenkins Admin 계정 초기 패스워드 
```bash
cat /var/lib/jenkins/secrets/initialAdminPassword 
```
`해당 파일 내용을 복사하여 붙이고 플러그인 설치 진행.`
<br>
