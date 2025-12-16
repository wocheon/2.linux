#!/bin/bash

# free -h 명령어를 통해 메모리와 swap 값을 읽어서 파싱
mem_line=$(free -h | grep Mem:)
swap_line=$(free -h | grep Swap:)

mem_total=$(echo $mem_line | awk '{print $2}')
mem_available=$(echo $mem_line | awk '{print $7}')
mem_used=$(echo $mem_line | awk '{print $3}')

swap_total=$(echo $swap_line | awk '{print $2}')
swap_used=$(echo $swap_line | awk '{print $3}')

# 현재 메모리 사용률 계산 (단위 값이 문자 포함이므로 계산은 KB 기반으로 직접 수행)
mem_total_kb=$(free | awk '/Mem:/ {print $2}')
mem_available_kb=$(free | awk '/Mem:/ {print $7}')
swap_used_kb=$(free | awk '/Swap:/ {print $3}')

mem_used_percent=$(( 100 - (mem_available_kb * 100 / mem_total_kb) ))

if [ "$swap_total" == "0B" ] || [ "$swap_total" == "0" ]; then
  swap_used_percent=0
else
  swap_used_percent=$(( 100 * swap_used_kb / $(free | awk '/Swap:/ {print $2}') ))
fi

# swap 정리 후 예상 메모리 사용률 계산 (swap_used 만큼 available 감소)
mem_used_percent_after=$(( mem_used_percent + (100 * swap_used_kb / mem_total_kb) ))

# 출력
echo "* VM Name : $(hostname) IP : $(hostname -i | gawk '{print $1}')"
echo "- 메모리 Total: ${mem_total}"
echo "- 메모리 Available: ${mem_available}"
echo "- 메모리 Used: ${mem_used}"
echo "- Swap Used: ${swap_used}"
echo "- Swap 사용률: ${swap_used_percent}%"
echo "- 현재 메모리 사용률: ${mem_used_percent}%"
echo "- swap 정리 후 예상 메모리 사용률: ${mem_used_percent_after}%"

# 조건 판단 및 결과 출력
if [ "$swap_used_percent" -ge 10 ]; then
  if [ "$mem_used_percent_after" -lt 85 ]; then
    echo "> Swap 사용률이 ${swap_used_percent}% 이고, swap 정리 후 예상 메모리 사용률이 ${mem_used_percent_after}% 이므로 swap 정리가 가능합니다."
  else
    echo "> Swap 사용률이 ${swap_used_percent}% 이고, swap 정리 후 예상 메모리 사용률이 ${mem_used_percent_after}% 로 80% 이상이므로 swap 정리가 불가능합니다."
  fi
else
  echo "> Swap 사용률이 ${swap_used_percent}% 으로 정리할 필요가 없습니다."
fi

