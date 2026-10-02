# Jenkins 설치와 Agent

Jenkins 설치, 실습용 GitLab 준비, Agent 연결을 한곳에 모았습니다.

---

## Jenkins 설치 및 기본 설정

기본 환경: Ubuntu 24.04 LTS. Jenkins LTS의 Java 지원 범위는 설치 전에 [공식 정책](https://www.jenkins.io/doc/book/platform-information/support-policy-java/)을 확인합니다. 아래 예제는 Java 21을 사용합니다.

### Jenkins 설치 (Ubuntu 24.04 LTS)
```bash
sudo apt update
sudo apt install -y fontconfig openjdk-21-jre curl
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  -o /usr/share/keyrings/jenkins-keyring.asc
echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' \
  | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo systemctl status jenkins
```

### Rocky Linux 9 대안
```bash
sudo dnf install -y fontconfig java-21-openjdk curl
sudo curl -fsSL https://pkg.jenkins.io/redhat-stable/jenkins.repo \
  -o /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install -y jenkins
sudo systemctl enable --now jenkins
```

### 접속 확인
- 테스트 URL: `http://서버_IP:8080` (운영 시 HTTPS 역방향 프록시와 접근 제한 적용)
- 초기 관리자 암호: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- 빌드 Agent에도 프로젝트가 요구하는 JDK·Maven을 별도로 설치합니다.

참고: [Jenkins Linux 설치](https://www.jenkins.io/doc/book/installing/linux/), [지원 Java 버전](https://www.jenkins.io/doc/book/platform-information/support-policy-java/)


---

## 실습용 GitLab 설치

Ubuntu 24.04 LTS와 Docker Compose v2 기준입니다. RHEL 계열 실습은 Rocky Linux 9를 사용합니다.

### 설치

- [GitLab Compose 설치](../../git/gitlab/gitlab.md) 절차를 사용합니다.
- Registry를 쓰는 경우 [GitLab TLS Registry 구성](../../git/gitlab/GitLab_TLS_Registry_구성.md)을 함께 적용합니다.
- Jenkins의 GitLab URL은 `https://gitlab.example.com`으로 설정합니다.

### 확인

```bash
docker compose ps
docker compose logs -f gitlab
```

초기 관리자 비밀번호는 Compose 작업 디렉터리의 `gitlab/config/initial_root_password`에서 확인합니다.


---

## SSH Agent 연결

> **용어 안내:** 기존 화면 기록의 Agent/Controller는 현재 Jenkins의 Agent/Controller에 해당합니다.

### Jenkins Publish Over SSH 설정

#### Publish Over SSH Plugin 설치
 * jenkins 관리 > Plugins > available Plugins 에서
	- ssh 검색 >  Publish Over SSH 선택하여 설치

#### Publish Over SSH 설정
* jenkins 관리 >SYSTEM > Publish over SSH
	- key 부분에 개인키 입력 ( id_rsa )
	- ssh Server에 Agent Node 정보 입력
		- name : Node 이름
		- hostname : Node ip
		- Username : SSH 접속 계정 (예: deploy)
		- Remote Directory : 접속 시 기본 디렉토리 <br>

	- Test Configuration에서 성공하면 설정 완료.


### Agent NODE 연결

#### 노드 연결시 체크 사항
	* JDK 설치 (version : 11)
	* SSH 공개키 등록 ( Authorized_keys에 Controller 노드 공개키 입력)
	* 22 port OPEN 상태

#### SSH 키 교환 및 Cendidental 등록
- 마스터 노드에서 key 생성

	```bash
	ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
	```
	<br>

- Agent 노드의 ~/.ssh/authorized_keys 공개키 입력 후 접속 확인

$\textcolor{orange}{\textsf{ * 키를 pem 파일로 생성 }}$


- openssl rsa -in id_rsa -outform PEM -out id_rsa.pem
	 `pem파일 생성하여 scp등에서 사용`


#### Agent Node추가
- jenkins 관리 > Nodes > New Node
	- 노드명 입력 및 Permanent Agent 선택 후 create

- Agent Node 옵션
	- Number of executors : 한번에 진행가능한 JOB개수 결정
	- Labels : agent (임의로 지정 후  pipeline 스크립트 등에서 명시하여 사용)
	- Remote root directory : /home/jenkins/agent (미리 디렉토리 생성 필요)
	- Launch method : Launch agents via SSH
	- Host : Agent Node IP
	- Credentials : 없는 경우 새로 추가
	- jenkins credentials provider: Jenkins
		- domain : global
		- kind : SSH Username with private Key
		- scope : global
		- ID : 임의로 지정
		- UserName : SSH 접속계정
		- Private Key : Enter directly 선택 후 마스터 노드의 개인키 값을 입력

	- Host Key Verification Strategy : Known hosts file Verification Strategy

* `Controller 노드에서 /var/lib/jenkins/.ssh/ 디렉토리 생성 후, .ssh에 있는 known_hosts를 복사해둘것 `
	- Controller에서 agent 추가대상에 ssh 접속하면 known_host가 추가되므로 해당 내용을  /var/lib/jenkins/.ssh/known_hosts에 복사


	- 고급
		- Port : SSH Port
		- JavaPath : Agent Node의 JAVA위치 ( readlink -f /bin/java )

- 생성 완료 후 Launch agent 연결 진행.
` Console Output으로 오류발생하는지 로그정보를 확인 `
<br>
