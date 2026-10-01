#!/bin/bash

### gcloud_promethes_배치부하분산_스크립트.sh ####
# GCP의 특정 zone 및 이름 패턴을 가진 VM들의 내부 IP를 가져와
# Prometheus 서버에서 각 VM의 load1, 메모리 사용률, VRAM
# 사용률을 쿼리하여 가장 부하가 적은 VM을 선택하는 스크립트

PROM_URL="[PROMETHEUS_SERVER_IP]:9090"
ZONE="asia-northeast3-b"
NAME_FILTER="xlarge-vm-*"

# 1. gcloud로 특정 zone 및 이름 필터로 VM 내부 IP 리스트 획득
vm_ips=$(gcloud compute instances list \
          --zones="$ZONE" \
          --filter="name:$NAME_FILTER" \
          --format="value(INTERNAL_IP)")

if [ -z "$vm_ips" ]; then
  echo "No matching VMs found"
  exit 1
fi

# 2. Prometheus 쿼리 함수 (1분 평균 load1, 값만 추출)
query_prometheus() {
  local ip=$1
  local query=$2
  value=$(curl -sG "$PROM_URL/api/v1/query" --data-urlencode "query=$query" \
    | jq -r '.data.result[0].value[1] // "N/A"')

  if [[ "$value" == "N/A" ]]; then
    echo "$value"
  else
    # 반올림: awk 사용, 소수점 둘째 자리까지만 출력
    printf "%.2f\n" "$(awk "BEGIN {print ($value+0.005)}")"
  fi
}

declare -A load
declare -A mem
declare -A vram

# 3. 각 VM에 대해 쿼리 실행 및 출력
for ip in $vm_ips; do
 # load=$(query_prometheus "$ip" "avg_over_time(node_load1{instance=\"$ip:9100\"}[1m])")
  load=$(query_prometheus "$ip" "sum by (instance) (node_load1{instance=\"$ip:9100\"}) / count by(instance) (node_cpu_seconds_total{mode=\"system\", instance=\"$ip:9100\"})")
  mem=$(query_prometheus "$ip" "100 * (1 - (node_memory_MemAvailable_bytes{instance=\"$ip:9100\"} / node_memory_MemTotal_bytes{instance=\"$ip:9100\"}))")
  vram=$(query_prometheus "$ip" "avg(DCGM_FI_DEV_FB_USED{instance=\"$ip:9400\"}/(DCGM_FI_DEV_FB_FREE{instance=\"$ip:9400\"}+DCGM_FI_DEV_FB_USED{instance=\"$ip:9400\"})*100)")

  load["$ip"]=$load
  mem["$ip"]=$mem
  vram["$ip"]=$vram
  #echo "VM IP: $ip, 1min Load: $load, Mem_usage: $mem, Vram_Usage: $vram"
  echo "VM IP: $ip, Load(1m)/Cores: ${load["$ip"]}, Mem(%): ${mem["$ip"]}, Vram(%): ${vram["$ip"]}"
done

# 4. VM 리스트 순회하며 최적 VM 탐색 (10점 만점)
best_vm=""
best_score=-1  # 점수가 클수록 좋음

echo "VM Score Summary:"
echo "IP Address      Load Score  Mem Score  VRAM Score  Total Score"

for ip in $vm_ips; do
  load_usage=${load[$ip]:-100}   # 0~100 가정 (load는 0~1이면 *100 변환 필요)
  mem_usage=${mem[$ip]:-100}
  vram_usage=${vram[$ip]:-100}

  load_score=$(echo "scale=2; (100 - $load_usage) / 10" | bc)
  mem_score=$(echo "scale=2; (100 - $mem_usage) / 10" | bc)
  vram_score=$(echo "scale=2; (100 - $vram_usage) / 10" | bc)

#  total_score=$(echo "$load_score + $mem_score + $vram_score" | bc)
  # 현재 기준 : Load(4), Mem(4), VRAM(2)
  total_score=$(echo "scale=2; $load_score * 0.4 + $mem_score * 0.4 + $vram_score * 0.2" | bc)

  printf "%-15s %10s %10s %11s %12s\n" "$ip" "$load_score" "$mem_score" "$vram_score" "$total_score"

  if (( $(echo "$total_score > $best_score" | bc) )); then
    best_score=$total_score
    best_vm=$ip
  fi
done

echo ""
echo "Best VM: $best_vm with total score: $best_score / 10"
