# VM 내 연결에서 사용가능한 소스포트 관련 사항 

## 개요 
- VM 환경에서 IP 연결 시 사용 가능한 소스포트(ephemeral 포트) 관련 점검 및 스크립트

요약:
- ephemeral 포트 범위 확인 방법
- IP(또는 원격 호스트)별 실제 사용 중인 소스포트 개수를 계산하는 bash 스크립트
- 소스포트 고갈(Exhaustion) 여부 확인 방법 및 징후
- netstat -tnop를 이용해 CLOSE_WAIT 등의 세션 수 확인 방법(예시 명령어)

## 1) Ephemeral Port?
- 웹 브라우징이나 이메일 전송 같은 일시적인 통신을 위해 운영 체제에서 자동으로 할당하는 단기 포트
- 통신 세션이 종료되면 재사용을 위해 시스템에 반환
> ex) HTTP (80) 서버 접근시  클라이언트 측 통신시 임시 포트를 사용하여 접근 

## 2) ephemeral 포트(소스포트) 범위 확인
리눅스에서 로컬에서 할당되는 포트 범위는 다음 명령으로 확인합니다.
```bash
sysctl net.ipv4.ip_local_port_range
# 또는
cat /proc/sys/net/ipv4/ip_local_port_range
```
예: "32768 60999" -> 사용 가능한 포트 수 = 60999 - 32768 + 1 = 28232

계산 예:
```bash
low=$(awk '{print $1}' /proc/sys/net/ipv4/ip_local_port_range)
high=$(awk '{print $2}' /proc/sys/net/ipv4/ip_local_port_range)
total=$((high-low+1))
echo $total
```
주의:

- Ephemeral port 총 개수 = 실제로 사용 가능한 포트 개수가 아님.
- OS의 연결 상태, TIME_WAIT, NAT 테이블, FD 한도 등으로 인하여 실제 사용가능한 포트수는 더 적음
> ex) 특정 IP에 대한 연결 세션 수가 23830 개여도 소스포트 고갈로 인해 연결 불가 발생


## 3)소스포트 고갈(ephemeral port exhaustion) 진단 방법


- syslog / 애플리케이션 로그에 다음과 같은 메시지 다수 발생:
    - Cannot assign requested address
    - Address already in use
    - connect() failed

- netstat/ss에서 ephemeral 포트 사용량이 total에 근접
    - (예: used ≈ 28000/28232)

- TIME_WAIT 세션이 매우 많음

- 포트 빠른 재사용(= 포트 conflict)로 간헐적 연결 실패 발생

- 특정 source IP만 소스포트가 고갈되고, 다른 IP는 여유가 있음 (IP당 독립풀)

### 예시 - traceroute로 소스포트 고갈 여부 확인 
```bash
$ tcptraceroute [targetIP] [port]
bind: Address already in use
```
- 해당 메시지는 Source IP에서 사용가능한 ephemeral port가 모두 사용중이라는 뜻이므로 고갈 확인 가능
    - 확실히 확인하려면 실제 세션 수를 확인필요


## 3) 소스포트 고갈 여부(징후) 확인 방법
- syslog / application logs에서 "Cannot assign requested address", "Address already in use" 또는 connect 실패 에러 다수 발생
- netstat/ss로 ephemeral 포트 사용량이 거의 가득 찬 경우(used ≈ total)
- 많은 수의 TIME_WAIT 세션 (특히 short timeout 설정시)
- 포트 재사용 이상 징후: ephemeral 포트가 빠르게 재사용되어 연결 오류 발생

### ss 명령을 통해 확인 
```bash
# 소켓 상태 요약
ss -s

# TIME_WAIT, CLOSE_WAIT 수 확인
ss -tan state time-wait | wc -l
ss -tan state close-wait | wc -l
```

### netstat -tnop로 각 상태별 세션 수 확인
```
netstat -tnop | awk '/tcp/ {print $6}' | sort | uniq -c | sort -nr
```

### 참고 - ephemeral 포트 범위 확장
- 필요시 ephemeral 포트 범위 확장 가능

```bash
sysctl -w net.ipv4.ip_local_port_range="1024 65535"
```
### 추가 확인사항
- TIME_WAIT가 많은 경우: 소켓 재사용(net.ipv4.tcp_tw_reuse 등), 타임아웃(net.ipv4.tcp_fin_timeout) 등 커널 파라미터 검토(부작용 주의)
- 애플리케이션 레벨에서 연결 풀링, Keep-Alive, 재사용 전략 적용 고려


## 4) IP 연결당 실제 사용 가능한 소스포트 개수 확인하는 bash 스크립트
아래 스크립트는 원격 IP(또는 원격IP:포트)를 기준으로 현재 호스트에서 사용하는 고유한 로컬(소스) 포트 수를 세고, ephemeral 총수와 비교해 남은 가용 포트를 표시합니다.

```bash
#!/bin/bash

echo "==============================================="
echo " 🔍 리눅스 Outbound Ephemeral Port 실제 사용 가능 개수 계산"
echo "==============================================="

# 1. ephemeral port 범위
read MIN_PORT MAX_PORT < <(sysctl -n net.ipv4.ip_local_port_range)
TOTAL=$((MAX_PORT - MIN_PORT + 1))

echo "1) Ephemeral Port Range  : $MIN_PORT - $MAX_PORT"
echo "   → 총 포트 개수        : $TOTAL"

echo "-----------------------------------------------"

# 2. 현재 ESTABLISHED/TIME_WAIT outbound 사용량
ESTABLISHED=$(ss -ant | awk 'NR>1 && $1=="ESTAB"' | wc -l)
TIMEWAIT=$(ss -ant | awk 'NR>1 && $1=="TIME-WAIT"' | wc -l)

echo "2) 현재 ESTABLISHED 수   : $ESTABLISHED"
echo "3) 현재 TIME_WAIT 수      : $TIMEWAIT"

echo "-----------------------------------------------"

# 3. LISTEN 중인 포트 - outbound와 직접 관계 없음
LISTEN=$(ss -lnt | awk 'NR>1 {print $4}' | wc -l)
echo "4) LISTEN 중인 포트 수   : $LISTEN"

echo "-----------------------------------------------"

# 4. 파일 디스크립터 제한 (socket은 FD 1개 사용)
FD_SOFT=$(ulimit -n)
FD_HARD=$(ulimit -Hn)

echo "5) 파일 디스크립터 제한"
echo "   - soft limit : $FD_SOFT"
echo "   - hard limit : $FD_HARD"

echo "-----------------------------------------------"

# 5. 예약된 커널 내부 포트 (대략 500개 가정, 환경에 따라 조정 가능)
RESERVED=500

# 6. usable ports 계산
USABLE=$((TOTAL - ESTABLISHED - TIMEWAIT - RESERVED))

if (( USABLE < 0 )); then
    USABLE=0
fi

echo "6) 실제 사용 가능 Outbound Ephemeral Ports 예상:"
echo "   → $USABLE 개 사용 가능 (추정)"

echo "-----------------------------------------------"

# 7. NAT 환경인지 확인 (도커, GCP 등)
if ip r | grep -q "docker0"; then
    echo "⚠️ Docker NAT 환경 감지됨 → usable 포트가 40~70%로 감소할 수 있음."
fi

if curl -s http://metadata.google.internal >/dev/null 2>&1; then
    echo "⚠️ GCP VM 감지됨 → NAT일 경우 20~40% usable 감소 가능."
fi

echo "==============================================="

```