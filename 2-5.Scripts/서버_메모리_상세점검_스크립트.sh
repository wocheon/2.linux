#!/bin/bash

# ==============================================================================
# Description: 단위 자동 변환(MB/GB) 기능이 추가된 메모리 정밀 분석 리포트
# ==============================================================================

# --- 색상 설정 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- 함수: 값 추출 (KB 단위) ---
get_mem_val() {
    grep "^$1:" /proc/meminfo | awk '{print $2}'
}

# --- 1. 데이터 수집 ---
MEM_TOTAL=$(get_mem_val "MemTotal")
MEM_FREE=$(get_mem_val "MemFree")
MEM_AVAILABLE=$(get_mem_val "MemAvailable")

# 버퍼/캐시 관련
BUFFERS=$(get_mem_val "Buffers")
CACHED=$(get_mem_val "Cached")
SLAB_RECLAIM=$(get_mem_val "SReclaimable")
SLAB_UNRECLAIM=$(get_mem_val "SUnreclaim")

# 커널/시스템 관련
PAGE_TABLES=$(get_mem_val "PageTables")
KERNEL_STACK=$(get_mem_val "KernelStack")
VMALLOC_USED=$(get_mem_val "VmallocUsed")

# 프로세스/데이터 관련
ANON_PAGES=$(get_mem_val "AnonPages")
SHMEM=$(get_mem_val "Shmem")
MAPPED=$(get_mem_val "Mapped")

# I/O 관련
DIRTY=$(get_mem_val "Dirty")
WRITEBACK=$(get_mem_val "Writeback")

# --- 2. 계산 로직 ---

# 커널 사용량 (Kernel Used)
KERNEL_USED=$((SLAB_UNRECLAIM + PAGE_TABLES + KERNEL_STACK))

# 사용자 프로세스 사용량 (User Used)
USER_USED=$((ANON_PAGES + SHMEM))

# 순수 캐시 (Pure Cache)
PURE_CACHE=$((CACHED - SHMEM + SLAB_RECLAIM + BUFFERS))

# 실질 사용량 (Real Used)
REAL_USED=$((MEM_TOTAL - MEM_FREE - PURE_CACHE))

# --- 3. 유틸리티 함수: 단위 자동 변환 (핵심 변경 사항) ---
# 입력값(KB)이 1024MB(1048576KB) 이상이면 GB로, 아니면 MB로 출력
format_size() {
    awk -v val="$1" 'BEGIN {
        mb = val / 1024;
        if (mb >= 1024) {
            printf "%.2f GB", mb / 1024;
        } else {
            printf "%.0f MB", mb;
        }
    }'
}

# 퍼센트 계산 함수
calc_pct() {
    echo $(awk -v val="$1" -v tot="$MEM_TOTAL" 'BEGIN { printf "%.1f", (val / tot) * 100 }')
}

# 바 그래프 그리기 함수
draw_bar() {
    local pct=$(awk -v val="$1" 'BEGIN { printf "%.0f", val }')
    local bar_len=$((pct / 2)) # 50칸 만점
    local bar=""
    for ((i=0; i<bar_len; i++)); do bar="${bar}#"; done
    for ((i=bar_len; i<50; i++)); do bar="${bar}."; done
    echo -e "[${bar}] ${pct}%"
}

# --- 4. 리포트 출력 ---

clear
echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}            LINUX SERVER MEMORY SMART REPORT                ${NC}"
echo -e "${BOLD}================================================================${NC}"
echo -e "분석 시각: $(date)"
echo -e "전체 메모리: ${BOLD}$(format_size $MEM_TOTAL)${NC}"
echo ""

# [섹션 1] 종합 요약
REAL_USED_PCT=$(calc_pct $REAL_USED)
echo -e "${BOLD}1. 종합 메모리 점유 현황${NC}"
echo -e "   실질 사용량 (Kernel + App) : $(format_size $REAL_USED)"
echo -ne "   ${YELLOW}"
draw_bar $REAL_USED_PCT
echo -ne "${NC}"
echo -e "   > 남은 가용 메모리 (Available) : $(format_size $MEM_AVAILABLE) (캐시 포함 여유분)"
echo ""

# [섹션 2] 커널 메모리 (Kernel Space)
KERNEL_PCT=$(calc_pct $KERNEL_USED)
echo -e "${BOLD}2. 커널(OS) 사용 상세${NC} (시스템 구동 오버헤드)"
echo -e "   ------------------------------------------------------------"
echo -e "   ${BOLD}총 커널 사용량    : $(format_size $KERNEL_USED) (${KERNEL_PCT}%)${NC}"
echo -e "   ------------------------------------------------------------"
echo -e "   - Slab Unreclaim : $(format_size $SLAB_UNRECLAIM) \t(회수 불가 객체)"
echo -e "   - Page Tables    : $(format_size $PAGE_TABLES) \t(메모리 맵 테이블)"
echo -e "   - Kernel Stack   : $(format_size $KERNEL_STACK) \t(커널 스택)"
echo -e "   - Vmalloc Used   : $(format_size $VMALLOC_USED) \t(가상 할당)"
echo ""

# [섹션 3] 사용자 프로세스 (User Space)
USER_PCT=$(calc_pct $USER_USED)
echo -e "${BOLD}3. 프로세스/앱 사용 상세${NC} (실제 애플리케이션)"
echo -e "   ------------------------------------------------------------"
echo -e "   ${BOLD}총 프로세스 사용  : $(format_size $USER_USED) (${USER_PCT}%)${NC}"
echo -e "   ------------------------------------------------------------"
echo -e "   - Anon Pages     : $(format_size $ANON_PAGES) \t(앱 전용: Heap/Stack)"
echo -e "   - Shared Memory  : $(format_size $SHMEM) \t(공유 메모리)"
echo -e "   - Mapped File    : $(format_size $MAPPED) \t(파일 매핑)"
echo ""

# [섹션 4] 캐시 및 I/O 상태
CACHE_PCT=$(calc_pct $PURE_CACHE)
echo -e "${BOLD}4. 캐시 및 I/O 버퍼${NC} (성능 가속 / 회수 가능)"
echo -e "   ------------------------------------------------------------"
echo -e "   ${BOLD}총 캐시 용량      : $(format_size $PURE_CACHE) (${CACHE_PCT}%)${NC}"
echo -e "   ------------------------------------------------------------"
echo -e "   - Page Cache     : $(format_size $((CACHED - SHMEM))) \t(파일 캐시)"
echo -e "   - Slab Reclaim   : $(format_size $SLAB_RECLAIM) \t(dentry/inode)"
echo -e "   - Buffers        : $(format_size $BUFFERS) \t(I/O 버퍼)"
echo -e "   ------------------------------------------------------------"
echo -e "   [I/O 상태 점검]"
echo -e "   - Dirty Memory   : ${RED}$(format_size $DIRTY)${NC} \t(기록 대기 중)"
echo -e "   - Writeback      : $(format_size $WRITEBACK) \t(기록 중)"
echo ""

echo -e "${BOLD}================================================================${NC}"

# [진단 로직]
if [ "$SLAB_UNRECLAIM" -gt $((MEM_TOTAL / 10)) ]; then
    echo -e "${RED}[경고] 커널 메모리(Unreclaim)가 전체의 10%를 넘습니다. 누수 점검 필요.${NC}"
elif [ "$DIRTY" -gt 512000 ]; then
     echo -e "${YELLOW}[주의] Dirty 메모리가 500MB 이상입니다. 디스크 부하가 높습니다.${NC}"
else
    echo -e "${GREEN}[상태 양호] 특이사항이 발견되지 않았습니다.${NC}"
fi
echo -e "${BOLD}================================================================${NC}"
