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

# 사용법: ./check_port_limit.sh <TARGET_IP>
TARGET_IP=$1

# 색상 변수
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$TARGET_IP" ]; then
    echo -e "${RED}사용법 오류: 분석할 타겟 IP를 입력해주세요.${NC}"
    echo "예: ./check_port_limit.sh 1.2.3.4"
    exit 1
fi

# netstat 체크
if ! command -v netstat &> /dev/null; then
    echo -e "${RED}Error: 'netstat' 명령어가 없습니다. (yum install net-tools 또는 apt install net-tools)${NC}"
    exit 1
fi

echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE} 🔍 Port Exhaustion Analyzer (Target: $TARGET_IP)${NC}"
echo -e "${BLUE}========================================================${NC}"

# ==========================================
# 1. 물리적 한계치 정밀 계산 (Real Limit)
# ==========================================

# 1-1. 기본 범위
MIN_PORT=$(sysctl -n net.ipv4.ip_local_port_range | awk '{print $1}')
MAX_PORT=$(sysctl -n net.ipv4.ip_local_port_range | awk '{print $2}')
THEORETICAL_LIMIT=$((MAX_PORT - MIN_PORT + 1))

# 1-2. 커널 예약 포트 (Reserved) 제외
RESERVED_PORTS=$(sysctl -n net.ipv4.ip_local_reserved_ports)
RESERVED_COUNT=0

if [ -n "$RESERVED_PORTS" ]; then
    IFS=',' read -ra RANGES <<< "$RESERVED_PORTS"
    for RANGE in "${RANGES[@]}"; do
        if [[ "$RANGE" == *-* ]]; then
            START=${RANGE%-*}
            END=${RANGE#*-}
        else
            START=$RANGE
            END=$RANGE
        fi
        
        # 교집합 구간 계산
        REAL_START=$(( START > MIN_PORT ? START : MIN_PORT ))
        REAL_END=$(( END < MAX_PORT ? END : MAX_PORT ))
        
        if (( REAL_START <= REAL_END )); then
            COUNT=$(( REAL_END - REAL_START + 1 ))
            RESERVED_COUNT=$(( RESERVED_COUNT + COUNT ))
        fi
    done
fi

# 1-3. Listen 중인 포트 제외 (netstat 기반)
LISTEN_IN_RANGE=$(netstat -tln | awk -v min="$MIN_PORT" -v max="$MAX_PORT" '
    /^tcp/ {
        split($4, a, ":");
        port = a[length(a)];
        if (port >= min && port <= max) count++;
    }
    END { print count+0 }
')

# 1-4. 최종 한계치 도출
REAL_LIMIT=$(( THEORETICAL_LIMIT - RESERVED_COUNT - LISTEN_IN_RANGE ))

echo -e "1. 시스템 포트 한계치 분석"
echo "   👉 범위 설정 : $MIN_PORT ~ $MAX_PORT (총 $THEORETICAL_LIMIT 개)"
echo "   👉 차감 요소 : 예약됨(-$RESERVED_COUNT), 리스닝중(-$LISTEN_IN_RANGE)"
echo -e "   👉 ${GREEN}최종 가용 한계(Max Limit) : $REAL_LIMIT 개${NC}"
echo "--------------------------------------------------------"

# ==========================================
# 2. 타겟 IP 연결 상태 분석 (Target Analysis)
# ==========================================

# 2-1. 해당 IP와 맺은 전체 세션 수 확인
CURRENT_CONN=$(netstat -tn | grep "$TARGET_IP" | wc -l)

# 2-2. 상태별 상세 분석 (가장 중요한 CLOSE_WAIT 확인)
CONN_ESTAB=$(netstat -tn | grep "$TARGET_IP" | grep "ESTABLISHED" | wc -l)
CONN_CLOSE=$(netstat -tn | grep "$TARGET_IP" | grep "CLOSE_WAIT" | wc -l)
CONN_TIME=$(netstat -tn | grep "$TARGET_IP" | grep "TIME_WAIT" | wc -l)

echo -e "2. 타겟($TARGET_IP) 연결 현황"
echo -e "   👉 현재 총 연결 수 : $CURRENT_CONN 개"
echo "      ├─ ESTABLISHED : $CONN_ESTAB"
echo -e "      ├─ ${RED}CLOSE_WAIT  : $CONN_CLOSE${NC} (앱이 안 닫음)"
echo "      └─ TIME_WAIT   : $CONN_TIME (OS가 대기 중)"
echo "--------------------------------------------------------"

# ==========================================
# 3. 최종 진단 (Conclusion)
# ==========================================

REMAINING=$(( REAL_LIMIT - CURRENT_CONN ))
PERCENT=$(awk "BEGIN {printf \"%.2f\", ($CURRENT_CONN/$REAL_LIMIT)*100}")

echo -e "3. 최종 진단 결과"
echo "   👉 포트 점유율 : $PERCENT% ($CURRENT_CONN / $REAL_LIMIT)"

echo ""
if (( REMAINING <= 0 )); then
    echo -e "   🚨 ${RED}[CRITICAL] 연결 불가 (Source Port Exhaustion)${NC}"
    echo "      원인: 이 IP($TARGET_IP)로 할당 가능한 모든 소스 포트를 소진했습니다."
    echo "      분석: 잔여 포트가 $REMAINING개 입니다. (음수면 이미 초과)"
    if (( CONN_CLOSE > 1000 )); then
        echo "      👉 범인은 CLOSE_WAIT($CONN_CLOSE 개)입니다. 프로세스 재기동이 필요합니다."
    fi
elif (( REMAINING < 100 )); then
    echo -e "   🟠 ${YELLOW}[WARNING] 고갈 임박! (잔여: $REMAINING 개)${NC}"
    echo "      곧 연결 실패가 발생할 수 있습니다."
else
    echo -e "   🟢 ${GREEN}[SAFE] 정상 상태 (잔여: $REMAINING 개)${NC}"
    echo "      포트 문제는 아닙니다. 연결이 안 된다면 방화벽을 의심하세요."
fi

echo -e "${BLUE}========================================================${NC}"
```