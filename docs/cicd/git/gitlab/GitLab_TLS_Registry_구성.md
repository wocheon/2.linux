# GitLab TLS Registry 구성

[GitLab Compose 설치](gitlab.md)의 `gitlab.example.com:5050` Registry를 위한 테스트 절차입니다.

## 1. DNS와 인증서

- `gitlab.example.com`을 VM IP로 연결하고 TCP 443, 5050을 허용합니다.
- 신뢰 가능한 CA가 발급한 인증서와 키를 `gitlab/config/ssl/gitlab.example.com.crt`, `.key`에 배치합니다. 자체 CA로 발급했다면 Docker 클라이언트에도 해당 CA를 등록해야 합니다.
- 인증서에는 `gitlab.example.com`이 SAN으로 들어 있어야 합니다. 중간 인증서가 있다면 서버 인증서 파일에 이어 붙입니다.

```bash
mkdir -p gitlab/config/ssl
chmod 600 gitlab/config/ssl/gitlab.example.com.key
openssl x509 -in gitlab/config/ssl/gitlab.example.com.crt -noout -subject -dates
```

## 2. GitLab 설정

`gitlab.md`의 Compose 파일에 다음 값과 포트 매핑을 사용합니다. GitLab 웹과 Registry가 같은 인증서를 공유합니다.

```ruby
external_url 'https://gitlab.example.com'
registry_external_url 'https://gitlab.example.com:5050'
registry_nginx['ssl_certificate'] = '/etc/gitlab/ssl/gitlab.example.com.crt'
registry_nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/gitlab.example.com.key'
```

```bash
docker compose up -d
docker compose exec gitlab gitlab-ctl status registry
curl -I https://gitlab.example.com:5050/v2/
```

## 3. Docker 클라이언트에서 push/pull

자체 CA를 사용한다면 클라이언트마다 CA를 등록합니다. 공인 CA 인증서라면 이 단계는 건너뜁니다.

```bash
sudo mkdir -p /etc/docker/certs.d/gitlab.example.com:5050
sudo cp ca.crt /etc/docker/certs.d/gitlab.example.com:5050/ca.crt
sudo systemctl restart docker
```

GitLab 프로젝트의 Container Registry를 활성화하고, 해당 프로젝트에 push 권한이 있는 토큰으로 로그인합니다.

```bash
echo "$GITLAB_TOKEN" | docker login gitlab.example.com:5050 -u "$GITLAB_USER" --password-stdin
docker pull alpine:3.20
docker tag alpine:3.20 gitlab.example.com:5050/USER/PROJECT/alpine:test
docker push gitlab.example.com:5050/USER/PROJECT/alpine:test
docker pull gitlab.example.com:5050/USER/PROJECT/alpine:test
```

`USER/PROJECT`는 실제 프로젝트 경로로 바꿉니다. 인증서 오류가 나면 도메인·SAN·CA 신뢰 설정을 확인합니다.

참고: [GitLab Registry 관리](https://docs.gitlab.com/administration/packages/container_registry/), [Docker 인증서 설정](https://docs.docker.com/engine/security/certificates/)
