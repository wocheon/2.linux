#!/bin/bash

# ==============================================================================
# Description: CPU 상세 분석 (공백 파싱 오류 수정 버전)
# ==============================================================================

# --- 색상 설정 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- 1. 기본 정보 수집 ---
CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
CORE_COUNT=$(grep -c processor /proc/cpuinfo)
LOAD_1MIN=$(awk '{print $1}' /proc/loadavg)
LOAD_5MIN=$(awk '{print $2}' /proc/loadavg)
LOAD_15MIN=$(awk '{print $3}' /proc/loadavg)

# --- 2. CPU 사용률 계산 함수 (read 대신 awk 사용) ---
get_cpu_usage() {
    # 첫 번째 스냅샷 (awk로 정확한 필드 추출)
    # /proc/stat format: cpu user nice system idle iowait irq softirq steal ...
    eval $(grep '^cpu ' /proc/stat | awk '{
        total = $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9;
        print "TOTAL_1=" total;
        print "IDLE_1=" $5;
        print "IO_1=" $6;
        print "USER_1=" $2;
        print "SYS_1=" $4;
        print "STEAL_1=" $9;
    }')

    sleep 1

    # 두 번째 스냅샷
    eval $(grep '^cpu ' /proc/stat | awk '{
        total = $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9;
        print "TOTAL_2=" total;
        print "IDLE_2=" $5;
        print "IO_2=" $6;
        print "USER_2=" $2;
        print "SYS_2=" $4;
        print "STEAL_2=" $9;
    }')

    # 델타 계산
    DIFF_TOTAL=$((TOTAL_2 - TOTAL_1))
    DIFF_IDLE=$((IDLE_2 - IDLE_1))
    DIFF_IO=$((IO_2 - IO_1))
    DIFF_USER=$((USER_2 - USER_1))
    DIFF_SYS=$((SYS_2 - SYS_1))
    DIFF_STEAL=$((STEAL_2 - STEAL_1))

    # 퍼센트 계산 (0으로 나누기 방지 로직 추가)
    if [ "$DIFF_TOTAL" -eq 0 ]; then
        USAGE_PCT=0; IO_PCT=0; SYS_PCT=0; USER_PCT=0; STEAL_PCT=0
    else
        USAGE_PCT=$(awk -v diff="$DIFF_TOTAL" -v idle="$DIFF_IDLE" 'BEGIN { printf "%.1f", ((diff - idle) / diff) * 100 }')
        IO_PCT=$(awk -v val="$DIFF_IO" -v tot="$DIFF_TOTAL" 'BEGIN { printf "%.1f", (val / tot) * 100 }')
        SYS_PCT=$(awk -v val="$DIFF_SYS" -v tot="$DIFF_TOTAL" 'BEGIN { printf "%.1f", (val / tot) * 100 }')
        USER_PCT=$(awk -v val="$DIFF_USER" -v tot="$DIFF_TOTAL" 'BEGIN { printf "%.1f", (val / tot) * 100 }')
        STEAL_PCT=$(awk -v val="$DIFF_STEAL" -v tot="$DIFF_TOTAL" 'BEGIN { printf "%.1f", (val / tot) * 100 }')
    fi
}

# --- 3. 유틸리티 함수 ---
draw_bar() {
    local pct=$(printf "%.0f" "$1")
    local bar_len=$((pct / 2))
    local bar=""
    for ((i=0; i<bar_len; i++)); do bar="${bar}#"; done
    for ((i=bar_len; i<50; i++)); do bar="${bar}."; done
    echo -e "[${bar}] ${pct}%"
}

float_gt() {
    awk -v val="$1" -v limit="$2" 'BEGIN { if (val > limit) print 1; else print 0; }'
}

# --- 4. 메인 실행 및 출력 ---
echo -e "${BOLD}측정 중... (1초 소요)${NC}"
get_cpu_usage

clear
echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}             LINUX SERVER CPU DEEP DIVE REPORT              ${NC}"
echo -e "${BOLD}================================================================${NC}"
echo -e "모델명      : $CPU_MODEL"
echo -e "코어 수     : ${BOLD}${CORE_COUNT} Cores${NC}"
echo -e "Load Avg    : $LOAD_1MIN (1m), $LOAD_5MIN (5m), $LOAD_15MIN (15m)"
echo ""

# [섹션 1] 전체 사용률
echo -e "${BOLD}1. 전체 CPU 사용률${NC}"
echo -ne "   Total Usage      : "
if [ $(float_gt "$USAGE_PCT" 80) -eq 1 ]; then
    echo -ne "${RED}"
else
    echo -ne "${GREEN}"
fi
draw_bar $USAGE_PCT
echo -ne "${NC}"
echo ""

# [섹션 2] 상세 분석
echo -e "${BOLD}2. 상세 워크로드 분석${NC}"
echo -e "   ------------------------------------------------------------"
echo -e "   - User Space     : ${USER_PCT}% \t(애플리케이션 처리)"
echo -e "   - Kernel (Sys)   : ${SYS_PCT}% \t(시스템 콜, 인터럽트 처리)"
echo -e "   ------------------------------------------------------------"
echo -e "   ${BOLD}[병목 진단 지표]${NC}"

# I/O Wait 체크
echo -ne "   - I/O Wait       : ${IO_PCT}% \t"
if [ $(float_gt "$IO_PCT" 10) -eq 1 ]; then
    echo -e "${RED}(주의: 디스크/네트워크 병목)${NC}"
else
    echo -e "${GREEN}(양호)${NC}"
fi

# Steal Time 체크
echo -ne "   - Steal Time     : ${STEAL_PCT}% \t"
if [ $(float_gt "$STEAL_PCT" 5) -eq 1 ]; then
    echo -e "${RED}(경고: 호스트 자원 경합)${NC}"
else
    echo -e "${GREEN}(양호)${NC}"
fi
echo ""

# [섹션 3] Load Average 분석
# 변수명 충돌 방지: load -> load_val
LOAD_PER_CORE=$(awk -v load_val="$LOAD_1MIN" -v cores="$CORE_COUNT" 'BEGIN { printf "%.2f", load_val / cores }')

echo -e "   - 1분 평균 Load  : $LOAD_1MIN"
echo -e "   - 코어당 Load    : ${LOAD_PER_CORE}"

if [ $(float_gt "$LOAD_PER_CORE" 1.0) -eq 1 ]; then
    echo -e "   ${RED}>>> 상태: 과부하 (Overloaded) - 대기열 발생 중${NC}"
elif [ $(float_gt "$LOAD_PER_CORE" 0.7) -eq 1 ]; then
    echo -e "   ${YELLOW}>>> 상태: 혼잡 (Busy) - 여유 적음${NC}"
else
    echo -e "   ${GREEN}>>> 상태: 쾌적 (Idle) - 여유 충분${NC}"
fi
echo ""

# [섹션 4] TOP 5 프로세스
echo -e "${BOLD}4. CPU 과다 점유 프로세스 (TOP 5)${NC}"
echo -e "   ------------------------------------------------------------"
printf "   %-8s %-8s %-6s %-6s %s\n" "PID" "USER" "%CPU" "%MEM" "COMMAND"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6 | tail -n 5 | awk '{printf "   %-8s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $5}'
echo -e "${BOLD}================================================================${NC}"
