# HAProxy 세팅 관련

## HAProxy Stat Page Settings
- Url 설정시 접속 방법
  - http://[haproxy 서버 주소]:8080/haproxy/stats

```bash
listen stats *:8080
        mode http
        stats enable
        stats refresh 10s
        stats hide-version
        stats uri /haproxy/stats
        stats auth admin:admin
        http-request set-log-level silent
```

## HAProxy Failover Settings
- backup으로 설정시 평소에는 대기하다가 master 서버에 장애 발생 시 트래픽을 전달
```bash
frontend f_web
        bind *:80
        mode http
        option httplog
        default_backend web

backend web
        balance roundrobin
        option forwardfor
        server web-1 192.168.1.10:80 check #master
        server web-2 192.168.1.105:80 check backup #backup
```