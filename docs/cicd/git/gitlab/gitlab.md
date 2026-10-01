# GitLab 설치

> Ubuntu 24.04 LTS 기준 테스트 예제입니다. RHEL 계열은 Rocky Linux 9와 Docker Compose Plugin을 사용합니다.

## 테스트 환경

- VM: 최소 4 vCPU, 8 GB RAM 권장. 필요한 용량은 저장소와 CI 사용량에 따라 조정합니다.
- 도메인: `gitlab.example.com`을 VM IP로 연결합니다.
- 방화벽: TCP 443, 5050 및 필요한 경우 SSH 포트를 허용합니다.
- Registry TLS 인증서는 [GitLab TLS Registry 구성](GitLab_TLS_Registry_구성.md)을 먼저 참고합니다.

## Docker Compose v2 설치

Ubuntu 24.04 LTS:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
docker compose version
```

Rocky Linux 9에서는 `sudo dnf install -y dnf-plugins-core` 후 Docker의 [RHEL 저장소](https://docs.docker.com/engine/install/rhel/)를 등록하고 `docker-ce docker-ce-cli containerd.io docker-compose-plugin`을 설치합니다.

## GitLab Compose 파일

인증서와 개인키를 `./gitlab/config/ssl/gitlab.example.com.crt`, `gitlab.example.com.key`에 준비합니다. 인증서의 SAN에 `gitlab.example.com`이 포함되어야 합니다.

> docker-compose.yml

```yaml
services:
  gitlab:
    image: gitlab/gitlab-ce:latest # 테스트용; 장기 운영 시 검증한 버전으로 고정
    hostname: gitlab.example.com
    restart: unless-stopped
    shm_size: 256m
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab.example.com'
        registry_external_url 'https://gitlab.example.com:5050'
        gitlab_rails['gitlab_shell_ssh_port'] = 10022
        letsencrypt['enable'] = false
        nginx['ssl_certificate'] = '/etc/gitlab/ssl/gitlab.example.com.crt'
        nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/gitlab.example.com.key'
        registry_nginx['ssl_certificate'] = '/etc/gitlab/ssl/gitlab.example.com.crt'
        registry_nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/gitlab.example.com.key'
    ports:
      - '443:443'
      - '5050:5050'
      - '10022:22'
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/logs:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'
```

```bash
mkdir -p gitlab/config/ssl gitlab/logs gitlab/data
chmod 600 gitlab/config/ssl/gitlab.example.com.key
docker compose up -d
docker compose logs -f gitlab
```

## 접속 확인

- 웹: `https://gitlab.example.com`
- 초기 관리자 비밀번호: `sudo cat gitlab/config/initial_root_password`
- Registry: `https://gitlab.example.com:5050/v2/` (`401 Unauthorized` 응답은 인증 전 정상 동작)
- 이미지 push/pull: [GitLab TLS Registry 구성](GitLab_TLS_Registry_구성.md)

[GitLab Docker 설치](https://docs.gitlab.com/install/docker/installation/) · [Registry 관리](https://docs.gitlab.com/administration/packages/container_registry/)
