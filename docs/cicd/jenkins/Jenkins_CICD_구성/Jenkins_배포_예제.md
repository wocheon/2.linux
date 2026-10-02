# Jenkins 배포 예제

Maven·Tomcat 테스트와 GitLab Container Registry에서 단일 VM으로 배포하는 Compose v2 예제입니다.

---

## Maven 빌드와 Tomcat 배포

기본 환경: Ubuntu 24.04 LTS, Eclipse Temurin JDK 25 LTS, Tomcat 11.0.26. Tomcat 11은 Jakarta Servlet 기반이므로 기존 `javax.*` 애플리케이션은 `jakarta.*`로 이관한 뒤 사용합니다. 레거시 WAR를 그대로 테스트해야 한다면 호환 Tomcat 버전을 별도 선택합니다.

### 빌드 환경
Jenkins Agent에 JDK 25와 Maven을 설치합니다. Adoptium 저장소 설정은 [Tomcat WAS 설치 예제](../../../platforms/tomcat/tomcat_apache_연동%28web-was%29.md)의 JDK 절을 참고합니다.

```bash
# Adoptium 저장소 구성 후
sudo apt install -y temurin-25-jdk maven
java -version
mvn -version
```

Rocky Linux 9에서는 Adoptium RPM 저장소를 구성하고 `sudo dnf install -y temurin-25-jdk maven`을 사용합니다.

### Tomcat 컨테이너로 테스트 배포
프로젝트의 `pom.xml`은 Jakarta API와 JDK 25에서 빌드 가능한 버전이어야 합니다.

```bash
mvn clean package
cp target/*.war ROOT.war
```

`Dockerfile`:
```dockerfile
FROM tomcat:11.0.26-jdk25-temurin-noble
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ROOT.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
```

```bash
docker build -t web-app:test .
docker run --rm -d --name web-app -p 8090:8080 web-app
curl -I http://localhost:8090/
```

Jenkins Pipeline에서는 Checkout → `mvn clean package` → Docker 빌드·배포 순서로 연결합니다. 테스트 컨테이너 배포 시 기존 컨테이너 중지는 테스트 환경에서만 수행하고, 운영 환경은 별도 배포 정책을 따릅니다.

참고: [Tomcat 11 다운로드](https://tomcat.apache.org/download-11), [Tomcat 11 마이그레이션](https://tomcat.apache.org/migration-11.0.html), [Tomcat 공식 이미지](https://hub.docker.com/_/tomcat)


---

## GitLab Registry에서 단일 VM에 Docker Compose v2로 배포

Jenkins는 WAR·이미지를 빌드하고 테스트한 뒤 TLS GitLab Registry에 push합니다. 별도 Ubuntu 24.04 LTS 테스트 VM은 해당 이미지를 pull해 Compose v2로 컨테이너를 갱신합니다. Kubernetes 배포는 Jenkins에서 `kubectl apply`를 실행하지 않고 [Argo CD 예제](../../argocd/ArgoCD_GKE/2.GSR_ArgoCD_연동.md)를 사용합니다.

### 준비

- Jenkins Docker Agent: Maven, Docker Engine, Registry push 권한이 있는 `gitlab-registry` Username/Password Credentials.
- 배포 VM: Docker Engine·Compose v2, `/opt/mvn-project` 디렉터리와 Docker 사용 권한이 있는 배포 계정. 해당 계정으로 TLS Registry에 `read_registry` 범위의 토큰을 사용해 미리 로그인합니다.
- Jenkins: `vm-deploy-ssh` SSH private key Credentials와 배포 VM의 SSH host key 등록. Docker 사용 권한은 호스트의 높은 권한이므로 격리된 테스트 환경에서 사용합니다.
- 애플리케이션 저장소: 위의 `Dockerfile`과 Maven `pom.xml`. Jenkins 작업은 "Pipeline script from SCM" 방식입니다.

배포 VM의 `/opt/mvn-project/compose.yaml`:

```yaml
services:
  app:
    image: "${APP_IMAGE:?set APP_IMAGE}"
    ports:
      - '8080:8080'
    restart: unless-stopped
```

### Jenkinsfile

Git 커밋의 짧은 해시를 이미지 태그로 사용합니다. Jenkins는 이미지 이름만 담긴 `.env`를 VM에 전송하고, VM에서 `docker compose pull` → `up -d`를 실행합니다.

```groovy
pipeline {
    agent { label 'docker' }
    environment {
        IMAGE = 'gitlab.example.com:5050/wocheon/mvn_project'
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package && cp target/*.war ROOT.war'
                script {
                    env.IMAGE_TAG = sh(script: 'git rev-parse --short=12 HEAD', returnStdout: true).trim()
                }
                sh 'docker build -t "$IMAGE:$IMAGE_TAG" .'
            }
        }
        stage('Smoke test') {
            steps {
                sh '''
                    set -eu
                    docker run --rm -d --name "mvn-smoke-$BUILD_NUMBER" \
                      -p 127.0.0.1:19090:8080 "$IMAGE:$IMAGE_TAG"
                    trap 'docker rm -f "mvn-smoke-$BUILD_NUMBER" >/dev/null 2>&1 || true' EXIT
                    curl --fail --retry 10 --retry-connrefused --retry-delay 2 \
                      http://127.0.0.1:19090/
                '''
            }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'gitlab-registry',
                    usernameVariable: 'REGISTRY_USER',
                    passwordVariable: 'REGISTRY_PASSWORD'
                )]) {
                    sh '''
                        set -eu
                        printf %s "$REGISTRY_PASSWORD" |
                          docker login gitlab.example.com:5050 \
                            -u "$REGISTRY_USER" --password-stdin
                        docker push "$IMAGE:$IMAGE_TAG"
                    '''
                }
            }
        }
        stage('Deploy to VM') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'vm-deploy-ssh',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh '''
                        set -eu
                        trap 'rm -f .env.deploy' EXIT
                        printf 'APP_IMAGE=%s:%s\n' "$IMAGE" "$IMAGE_TAG" > .env.deploy
                        scp -i "$SSH_KEY" -o StrictHostKeyChecking=yes \
                          .env.deploy "$SSH_USER@192.168.2.100:/opt/mvn-project/.env"
                        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=yes \
                          "$SSH_USER@192.168.2.100" \
                          'cd /opt/mvn-project && docker compose pull app && docker compose up -d --no-deps app && docker compose ps app'
                    '''
                }
            }
        }
    }
}
```

`IMAGE`와 VM 주소·경로를 테스트 환경에 맞게 바꿉니다. Registry 인증서는 [TLS Registry 구성](../../git/gitlab/GitLab_TLS_Registry_구성.md)을 참고합니다. Compose의 `.env`에는 이미지 주소만 저장하며 비밀번호는 넣지 않습니다. 운영 배포에는 승인·롤백·가용성 요구사항을 별도로 적용합니다.

참고: [Docker Compose pull](https://docs.docker.com/reference/cli/docker/compose/pull/), [Docker Compose up](https://docs.docker.com/reference/cli/docker/compose/up/), [Jenkins Credentials Binding](https://www.jenkins.io/doc/pipeline/steps/credentials-binding/)
