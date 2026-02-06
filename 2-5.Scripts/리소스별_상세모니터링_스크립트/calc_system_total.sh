#!/bin/bash

# ==============================================================================
# Script Name: calc_system_total.sh
# Description: 상세 디스크/포트 점검 포함 통합 리포트
# ==============================================================================

# --- 색상 설정 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- 헬퍼 함수 ---
print_status_val() {
    local val=$1; local limit=$2; local label=$3
    if [ "$val" -gt "$limit" ]; then
        echo -e "   - $label : ${RED}${BOLD}$val (주의)${NC}"
    else
        echo -e "   - $label : ${GREEN}$val (양호)${NC}"
    fi
}

detect_os() {
    if [ -f /etc/redhat-release ]; then
        OS_TYPE="RHEL"; PKG_CMD="yum"
    elif [ -f /etc/debian_version ]; then
        OS_TYPE="DEBIAN"; PKG_CMD="apt"
    else
        OS_TYPE="UNKNOWN"
    fi
}

# --- 메인 실행 ---
detect_os
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p)

clear
echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}            LINUX SERVER TOTAL HEALTH CHECK REPORT          ${NC}"
echo -e "${BOLD}================================================================${NC}"
echo -e "호스트명    : $HOSTNAME"
echo -e "OS 타입     : $OS_TYPE"
echo -e "커널 버전   : $KERNEL"
echo -e "가동 시간   : $UPTIME"
echo ""

# ------------------------------------------------------------------------------
# [섹션 1] 시스템 업데이트 상태
# ------------------------------------------------------------------------------
echo -e "${BOLD}1. 패키지 업데이트 상태${NC}"
echo -e "   ------------------------------------------------------------"
echo -ne "   업데이트 확인 중... "

if [ "$OS_TYPE" == "RHEL" ]; then
    TOTAL_UPDATES=$(yum check-update -q 2>/dev/null | grep -v "^$" | wc -l)
elif [ "$OS_TYPE" == "DEBIAN" ]; then
    TOTAL_UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l)
else
    TOTAL_UPDATES=0
fi

echo -e "\r   - 패키지 매니저  : $PKG_CMD"
echo -ne "   - 업데이트 대기  : "
if [ "$TOTAL_UPDATES" -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}$TOTAL_UPDATES 개${NC} (보안 패치 확인 필요)"
else
    echo -e "${GREEN}0 개 (최신 상태)${NC}"
fi
echo ""

# ------------------------------------------------------------------------------
# [섹션 2] 디스크 파티션 상태 (Type 추가, GCS Fuse 제외)
# ------------------------------------------------------------------------------
echo -e "${BOLD}2. 디스크 파티션 상태${NC} (로컬 파일시스템 위주)"
echo -e "   ---------------------------------------------------------------------------"
printf "   %-6s %-20s %-8s %-6s %-6s %s\n" "TYPE" "MOUNT POINT" "SIZE" "USED" "INODE" "STATUS"
echo -e "   ---------------------------------------------------------------------------"

# df -TP: 타입 포함 출력
# grep -vE: 제외할 파일시스템 및 마운트 경로 정의
df -TP -x tmpfs -x devtmpfs -x squashfs -x overlay | grep -vE '/boot|/snap|/run|fuse.gcsfuse' | tail -n +2 | while read -r fs type size used avail use_pct mount; do

    # Inode 정보 (df -iP)
    inode_raw=$(df -iP "$mount" 2>/dev/null | awk 'NR==2 {print $5}')

    # 숫자만 추출
    used_num=$(echo "$use_pct" | tr -dc '0-9')
    inode_num=$(echo "$inode_raw" | tr -dc '0-9')
    used_num=${used_num:-0}
    inode_num=${inode_num:-0}

    # 상태 판별
    status_msg="${GREEN}OK${NC}"
    if [ "$used_num" -ge 90 ] || [ "$inode_num" -ge 90 ]; then
        status_msg="${RED}CRITICAL${NC}"
    elif [ "$used_num" -ge 80 ] || [ "$inode_num" -ge 80 ]; then
        status_msg="${YELLOW}WARNING${NC}"
    fi

    printf "   %-6s %-20s %-8s %-6s %-6s %b\n" "${type:0:6}" "${mount:0:20}" "$size" "$use_pct" "$inode_raw" "$status_msg"
done
echo ""

# ------------------------------------------------------------------------------
# [섹션 3] 활성 서비스 포트 (테이블 형태)
# ------------------------------------------------------------------------------
echo -e "${BOLD}3. 활성 서비스 포트${NC} (LISTEN)"
echo -e "   ---------------------------------------------------------------------------"
printf "   %-8s %-10s %-25s %s\n" "PROTO" "PORT" "LOCAL ADDR" "PID/PROCESS"
echo -e "   ---------------------------------------------------------------------------"

# ss 명령어가 있으면 ss 사용 (더 빠르고 정확), 없으면 netstat 사용
if command -v ss &> /dev/null; then
    # ss -tulpn: TCP/UDP, Listening, Process name, Numeric port
    # 헤더 제외하고 내용 파싱
    ss -tulpn | grep LISTEN | awk '{
        # $1=Netid(tcp/udp), $5=Local(Address:Port), $7=Users
        split($5, addr, ":");
        port = addr[length(addr)];

        # 주소 정제 (:::80 -> *, 0.0.0.0:80 -> *)
        local_ip = $5;
        gsub(/:[0-9]+$/, "", local_ip);
        if(local_ip == "*" || local_ip == "::" || local_ip == "0.0.0.0") local_ip="ANY";

        # 프로세스 정보 정제 users:(("nginx",pid=1234,fd=6))
        proc_info = $7;
        gsub(/users:\(\("/, "", proc_info);
        gsub(/",pid=/, "/", proc_info);
        gsub(/,fd=[0-9]+\)\)/, "", proc_info);

        printf "   %-8s %-10s %-25s %s\n", $1, port, local_ip, proc_info
    }' | sort -k2 -n | head -n 15
else
    # netstat fallback
    netstat -tulpn 2>/dev/null | grep LISTEN | awk '{
        proto = $1;
        split($4, a, ":");
        port = a[length(a)];
        local_ip = $4;
        gsub(/:[0-9]+$/, "", local_ip);
        pid_prog = $7;

        printf "   %-8s %-10s %-25s %s\n", proto, port, local_ip, pid_prog
    }' | sort -k2 -n | head -n 15
fi
echo -e "   ... (Top 15 ports only)"
echo ""

# ------------------------------------------------------------------------------
# [섹션 4] 운영 안정성 및 장애 징후
# ------------------------------------------------------------------------------
echo -e "${BOLD}4. 운영 안정성 및 커널 징후${NC}"
echo -e "   ------------------------------------------------------------"
D_STATE=$(ps -eo state | grep "^D" | wc -l)
ZOMBIE=$(ps -eo state | grep "^Z" | wc -l)
print_status_val "$D_STATE" 0 "D-State (IO Lock)"
if [ "$D_STATE" -gt 0 ]; then
     echo -e "     ${RED}>>> [상세] 디스크 I/O 대기 중인 프로세스 존재!${NC}"
fi
print_status_val "$ZOMBIE" 5 "Zombie Process"

# 커널 에러 로그
OOM_CNT=$(dmesg | grep -i "Out of memory" | wc -l)
IO_ERR=$(dmesg | grep -iE "I/O error|EXT4-fs error|xfs_error" | wc -l)
print_status_val "$OOM_CNT" 0 "OOM Killer 발생"
if [ "$OOM_CNT" -gt 0 ]; then echo -e "     ${YELLOW}>>> 메모리 부족 이력 있음${NC}"; fi
print_status_val "$IO_ERR" 0 "디스크/FS 에러"
if [ "$IO_ERR" -gt 0 ]; then echo -e "     ${RED}>>> [심각] 파일시스템 손상 의심${NC}"; fi

echo ""
echo -e "${BOLD}================================================================${NC}"
