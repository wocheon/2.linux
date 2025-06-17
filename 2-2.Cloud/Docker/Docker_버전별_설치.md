# Docker 버전별 설치 방법

## Centos7

### docker 공식 repo 추가 
```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### 설치가능한 도커 버전 확인
```bash
yum list docker-ce --showduplicates | sort -r
```

### docker 최신버전 설치 
```bash
yum install -y docker-ce.x86_64
```

### 버전확인 
```bash
$ docker --version

Docker version 24.0.5, build ced0996
```

## Ubuntu 18.04
### 도커 설치에 필요한 패키지 다운로드
```bash
apt-get upgrade -y && apt-get update -y
apt-get install ca-certificates curl gnupg lsb-release
```

### 도커 공식 GPG key 등록	
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### 도커 Repository 설정
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 설치가능한  버전확인 
```
apt-cache policy docker-ce
```
  
### 도커 설치
```bash
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io  
```

## Ubuntu 20.04
### 도커 설치에 필요한 패키지 다운로드
```bash
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```

### 도커 공식 GPG key 등록	
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

### 도커 Repository 설정
```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

### 설치가능한  버전확인 
```
apt list -a docker-ce
```
  
### 도커 설치
```bash
apt install docker-ce=<VERSION> docker-ce-cli=<VERSION> containerd.io
```

