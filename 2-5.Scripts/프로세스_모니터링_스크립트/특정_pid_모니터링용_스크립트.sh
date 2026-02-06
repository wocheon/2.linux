#!/bin/bash

# 사용법: ./monitor.sh <PID>
PID=$1
INTERVAL=5  # 모니터링 간격(초)

if [ -z "$PID" ]; then
    echo "Usage: $0 <PID>"
    exit 1
fi

if ! ps -p $PID > /dev/null; then
    echo "프로세스 $PID가 존재하지 않습니다."
    exit 1
fi

while true; do
    clear
    echo "[$(date)] 프로세스 $PID 모니터링"

    # 1. 포트 사용 현황
    echo "## 포트 사용 현황"
    ss -ltnp | grep "pid=$PID" | awk '{print "포트:", $4, "상태:", $1}' || echo "포트 없음"
    echo

    # 2. CPU/메모리 사용량
    echo "## 리소스 사용량"
    CORES=$(nproc)  # 코어 수 확인
    PS_OUTPUT=$(ps -p $PID -o %cpu,%mem --no-headers)

    # CPU 계산 (코어 수로 나눔)
    RAW_CPU=$(echo $PS_OUTPUT | awk '{print $1}')
    CPU_PERCENT=$(echo "scale=2; $RAW_CPU / $CORES" | bc)
    echo "CPU 사용률(코어당): ${CPU_PERCENT}%"

    # 3. 디스크 및 스왑 사용량
    echo "## 스토리지 사용량"
    # 스왑 사용량 확인
    SWAP=$(grep VmSwap /proc/$PID/status 2>/dev/null | awk '{print $2}')
    echo "스왑 사용량: ${SWAP:-0} KB"

    # 디스크 I/O 확인 (읽기/쓰기 바이트)
    IOSTAT=$(cat /proc/$PID/io 2>/dev/null)
    READ_BYTES=$(echo "$IOSTAT" | grep 'read_bytes' | awk '{print $2}')
    WRITE_BYTES=$(echo "$IOSTAT" | grep 'write_bytes' | awk '{print $2}')
    echo "디스크 읽기: ${READ_BYTES:-0} bytes"
    echo "디스크 쓰기: ${WRITE_BYTES:-0} bytes"

    sleep $INTERVAL
done
