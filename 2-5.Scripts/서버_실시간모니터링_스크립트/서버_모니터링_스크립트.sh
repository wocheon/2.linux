#!/bin/bash

# 1. 로케일 강제 고정 (파싱 오류 방지)
export LC_ALL=C

function bg_grey (){
    echo -e "\E[47;30m$1\E[0m"
}

function bg_blue (){
    echo -e "\E[44;37m$1\E[0m"
}

function yellow (){
    echo -e "\E[;33m$1\E[0m"
}

# 2. OS 및 IP 정보 추출 최적화
host_nm=$(hostname)
# hostname -I를 사용하여 모든 IP를 가져온 뒤 첫 번째 IP 추출 (127.0.0.1 회피)
ip=$(hostname -I | awk '{print $1}')

# /etc/os-release 파일을 source 하여 PRETTY_NAME 변수를 직접 사용
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os=$PRETTY_NAME
else
    os=$(uname -srm)
fi

bg_grey "#Server Info"
# nproc 명령어로 논리 코어 수를 더 안전하게 가져옴
echo "$(yellow Hostname) : $host_nm $(yellow IP) : $ip $(yellow OS) : $os $(yellow vCPU) : $(nproc) $(yellow Memory) : $(free -h | awk '/^Mem:/ {print $2}')"
echo ""

bg_grey "#Uptime"
uptime
echo ""

bg_grey "#Top"
# 프로세스 스냅샷 용도 (CPU/Mem 상위 상태 확인)
top -b -n 1 | head -5

# /proc/stat을 활용한 실시간 CPU 사용률 계산 함수
function get_cpu_usage() {
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    local total_1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local idle_1=$idle

    sleep 1

    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    local total_2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local idle_2=$idle

    local total_diff=$((total_2 - total_1))
    local idle_diff=$((idle_2 - idle_1))

    local cpu_usage=$(( 100 * (total_diff - idle_diff) / total_diff ))
    echo "$cpu_usage"
}

CPU_USAGE=$(get_cpu_usage)
bg_blue "*CPU Usage (%) : ${CPU_USAGE}%"
echo ""

bg_grey "#sar (CPU Usage Detail)"
# sar가 설치되어 있지 않을 경우 에러를 무시하도록 처리
sar 1 1 2>/dev/null || echo "sar command not found. (sysstat package required)"
echo ""

bg_grey "#Memory"
free -h
# 3. 단일 I/O로 메모리 지표 추출 (중복 호출 제거)
read -r _ total use free shared buff_cache avail <<< $(free -m | grep "^Mem:")

# bc가 설치되어 있지 않은 환경을 대비해 awk 내장 연산 활용
use_per1=$(awk "BEGIN {printf \"%.2f\", ($total - $avail) / $total * 100}")
use_per2=$(awk "BEGIN {printf \"%.2f\", 100 - ($total - $use - $buff_cache) / $total * 100}")

bg_blue "*Memory Usage (Total - avail) (%) : $use_per1 %"
bg_blue "*Memory Usage (Total - use - buff_cache) (%) : $use_per2 %"
echo ""

bg_grey "#Disk usage"
# egrep 대신 grep -E 사용, 컨테이너 환경의 불필요한 마운트(overlay, squashfs 등) 추가 필터링
df -Th | grep -E -v '(tmpfs|share|/dev/loop|overlay|squashfs)'
echo " "

bg_grey "#Top 10 Process Sort by CPU Usage ( usage 1% over )"
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
# ps -aux 경고 방지를 위해 ps aux 사용. --sort=-%cpu 방식 권장
ps aux --sort=-%cpu | head -n 11 | awk '$3 >= 1.0'
echo " "

bg_grey "#Top 10 Process Sort by Memory Usage ( usage 1% over )"
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
ps aux --sort=-%mem | head -n 11 | awk '$4 >= 1.0'
echo ""