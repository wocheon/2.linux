# Docker - HTTP로 연결되는 Private Registry 사용방법


## Private Registry 연결시 

- Docker에서 HTTP로 연결되는 Private Registry에 insecure-registries로 등록하지 않으면 아래와 같은 에러 메시지가 발생
```sh
Error response from daemon: Get https://nexus.test-cicd.com/v2/: http: server gave HTTP response to HTTPS client
# OR
http: server gave HTTP response to HTTPS client
```


## 오류 해결 방법
### Linux 

- `/etc/docker/daemon.json` 파일 내 Insecure-Registry를 등록

> /etc/docker/daemon.json
```json
{
 "insecure-registries": [
    "nexus.test-cicd.com"
  ]
}
```

- 등록 확인

```sh
$ docker info | grep "Insecure Registries" -A 10
 Insecure Registries:
  hubproxy.docker.internal:5555
  nexus.test-cicd.com
  ::1/128
  127.0.0.0/8
 Live Restore Enabled: false
```


- docker 재시작 후 로그인 확인 
```sh
$ systemctl restart docker 

$ docker login nexus.test-cicd.com
Authenticating with existing credentials... [Username: docker-user]
i Info → To login with a different account, run 'docker logout' followed by 'docker login'
Login did not succeed, error: Error response from daemon: login attempt to http://nexus.test-cicd.com/v2/ failed with status: 401 Unauthorized
Username (docker-user): ciw0707
Password:
Login Succeeded
```


### Widows (Docker Desktop)

- Settings > Docker Engines 부분에 insecure-registies 추가 
```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "insecure-registries": [
    "nexus.test-cicd.com:80"
  ]
}
```


- Apply 후 확인

```sh
$ docker info | grep "Insecure Registries" -A 10
 Insecure Registries:
  hubproxy.docker.internal:5555
  nexus.test-cicd.com:80
  ::1/128
  127.0.0.0/8
 Live Restore Enabled: false
```