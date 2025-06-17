## HAProxy 접근 IP 목록 추출 
```sh
awk '{print $6, $11}' /var/log/haproxy/haproxy_0.log | sort | uniq -c | sort -nr
```

## HAProxy 접근 IP 별 HTTP Code 값 , Count 추출 
```sh
awk '{split($6, a, ":"); print a[1], $11}' /var/log/haproxy/haproxy_0.log | sort | uniq -c | sort -nr

# Hostname, IP, HTTP_code, Count 순으로 추출하기
HOSTNAME=$(hostname)
awk '{split($6, a, ":"); print a[1], $11}' /var/log/haproxy/haproxy_0.log | sort | uniq -c | sort -nr | awk -v host="$HOSTNAME" '{print host, $2, $3, $1}'

```
## HAProxy ACL 설정 
- 특정 IP 목록을 접근 불가 IP로 설정

> /etc/haproxy/haproxy.cfg 파일에 해당 구문 추가 
```sh
# Front/backend 에 추가 x (독립적으로 실행되는 구문임)
acl deny_ip src -f /etc/haproxy/denylist.txt
http-request deny if deny_ip
```
- /etc/haproxy/denylist.txt에 차단할 IP 목록 추가 
```
8.xxx.xxx.xxx
10.xxx.xxx.xxx
......
```

- HAProxy 설정 reload 
```sh
systemctl reload haproxy
```
