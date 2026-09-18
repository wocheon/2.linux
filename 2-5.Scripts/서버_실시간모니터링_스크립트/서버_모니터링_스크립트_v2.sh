#!/bin/bash

export LC_ALL=C

WATCH_INTERVAL=3
CPU_SAMPLE_INTERVAL=0.5

SCRIPT_PATH="$(readlink -f "$0")"


# ==============================================================================
# Options
# ==============================================================================

usage() {
    echo "Usage: $0 [-w [seconds]]"
    echo
    echo "  -w, --watch [seconds]   Watch mode (default: ${WATCH_INTERVAL}s)"
    echo "  -h, --help              Show help"
    echo
    echo "Examples:"
    echo "  bash $0"
    echo "  bash $0 -w"
    echo "  bash $0 -w 5"
}


case "${1:-}" in
    -w|--watch)
        interval="${2:-$WATCH_INTERVAL}"

        if ! [[ "$interval" =~ ^[1-9][0-9]*$ ]]; then
            echo "ERROR: Watch interval must be a positive integer."
            exit 1
        fi

        if ! command -v watch >/dev/null 2>&1; then
            echo "ERROR: watch command not found."
            exit 1
        fi

        exec watch \
            -c \
            -n "$interval" \
            -x \
            env \
            -u BASH_ENV \
            -u PROMPT_COMMAND \
            /bin/bash "$SCRIPT_PATH"
        ;;

    -h|--help)
        usage
        exit 0
        ;;

    "")
        ;;

    *)
        echo "ERROR: Unknown option: $1"
        usage
        exit 1
        ;;
esac


# ==============================================================================
# Color
# ==============================================================================

bg_grey() {
    printf '\033[47;30m%s\033[0m\n' "$1"
}

bg_blue() {
    printf '\033[44;37m%s\033[0m\n' "$1"
}

yellow() {
    printf '\033[33m%s\033[0m' "$1"
}


# ==============================================================================
# CPU Usage
# ==============================================================================

get_cpu_usage() {

    local cpu guest guest_nice

    local user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1
    local user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2

    local total1 total2 total_diff
    local user_diff system_diff
    local idle_diff iowait_diff steal_diff
    local busy_diff


    read -r cpu \
        user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 \
        guest guest_nice < /proc/stat


    total1=$(( \
        user1 + nice1 + system1 + idle1 + iowait1 + \
        irq1 + softirq1 + steal1 \
    ))


    sleep "$CPU_SAMPLE_INTERVAL"


    read -r cpu \
        user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 \
        guest guest_nice < /proc/stat


    total2=$(( \
        user2 + nice2 + system2 + idle2 + iowait2 + \
        irq2 + softirq2 + steal2 \
    ))


    total_diff=$((total2 - total1))


    if (( total_diff <= 0 )); then
        CPU_USAGE="0.0"
        CPU_USER="0.0"
        CPU_SYSTEM="0.0"
        CPU_IOWAIT="0.0"
        CPU_STEAL="0.0"
        CPU_IDLE="0.0"
        return
    fi


    user_diff=$(( \
        user2 - user1 + \
        nice2 - nice1 \
    ))


    system_diff=$(( \
        system2 - system1 + \
        irq2 - irq1 + \
        softirq2 - softirq1 \
    ))


    idle_diff=$((idle2 - idle1))
    iowait_diff=$((iowait2 - iowait1))
    steal_diff=$((steal2 - steal1))

    busy_diff=$((user_diff + system_diff))


    read -r \
        CPU_USAGE \
        CPU_USER \
        CPU_SYSTEM \
        CPU_IOWAIT \
        CPU_STEAL \
        CPU_IDLE < <(

        awk \
            -v busy="$busy_diff" \
            -v usr="$user_diff" \
            -v syscpu="$system_diff" \
            -v iowait="$iowait_diff" \
            -v steal="$steal_diff" \
            -v idle="$idle_diff" \
            -v total="$total_diff" \
            'BEGIN {
                printf "%.1f %.1f %.1f %.1f %.1f %.1f\n",
                    busy / total * 100,
                    usr / total * 100,
                    syscpu / total * 100,
                    iowait / total * 100,
                    steal / total * 100,
                    idle / total * 100
            }'
    )
}


# ==============================================================================
# PSI
# ==============================================================================

# PSI (Pressure Stall Information): CPU/Memory/I/O 자원 부족으로 작업이 대기한 비율을 표시

show_psi() {

    if [[ ! -d /proc/pressure ]]; then
        echo "PSI : Not supported"
        return
    fi


    for resource in cpu memory io; do

        if [[ -r "/proc/pressure/$resource" ]]; then

            some_avg10=$(awk '
                /^some/ {
                    for (i=1; i<=NF; i++) {
                        if ($i ~ /^avg10=/) {
                            split($i, a, "=")
                            print a[2]
                        }
                    }
                }
            ' "/proc/pressure/$resource")


            full_avg10=$(awk '
                /^full/ {
                    for (i=1; i<=NF; i++) {
                        if ($i ~ /^avg10=/) {
                            split($i, a, "=")
                            print a[2]
                        }
                    }
                }
            ' "/proc/pressure/$resource")


            case "$resource" in
                cpu)
                    printf "CPU PSI : some=%s%%\n" \
                        "${some_avg10:-0.00}"
                    ;;

                memory)
                    printf "MEM PSI : some=%s%% full=%s%%\n" \
                        "${some_avg10:-0.00}" \
                        "${full_avg10:-0.00}"
                    ;;

                io)
                    printf "I/O PSI : some=%s%% full=%s%%\n" \
                        "${some_avg10:-0.00}" \
                        "${full_avg10:-0.00}"
                    ;;
            esac
        fi
    done
}


# ==============================================================================
# Server Info
# ==============================================================================

host_nm=$(hostname)

ip=$(hostname -I 2>/dev/null | awk '{print $1}')

if [[ -z "$ip" ]]; then
    ip="N/A"
fi


if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    os="${PRETTY_NAME:-Unknown}"
else
    os=$(uname -srm)
fi


cpu_count=$(nproc)
mem_total=$(free -h | awk '/^Mem:/ {print $2}')


bg_grey "#Server Info"

echo "$(yellow Hostname): $host_nm  \
$(yellow IP): $ip  \
$(yellow OS): $os  \
$(yellow vCPU): $cpu_count  \
$(yellow Memory): $mem_total"

echo


# ==============================================================================
# Uptime / Load
# ==============================================================================

bg_grey "#Uptime / Load Average"

uptime -p

read -r load1 load5 load15 _ < /proc/loadavg

awk \
    -v l1="$load1" \
    -v l5="$load5" \
    -v l15="$load15" \
    -v cpu="$cpu_count" \
    'BEGIN {
        printf "Load : %.2f (%.0f%%) / %.2f (%.0f%%) / %.2f (%.0f%%)  [1m / 5m / 15m]\n",
            l1,  l1/cpu*100,
            l5,  l5/cpu*100,
            l15, l15/cpu*100
    }'

echo


# ==============================================================================
# CPU
# ==============================================================================

bg_grey "#CPU"

get_cpu_usage

bg_blue "*CPU Usage : ${CPU_USAGE}%"

printf "User:%5s%%  System:%5s%%  IOWait:%5s%%  Steal:%5s%%  Idle:%5s%%\n" \
    "$CPU_USER" \
    "$CPU_SYSTEM" \
    "$CPU_IOWAIT" \
    "$CPU_STEAL" \
    "$CPU_IDLE"

echo


# ==============================================================================
# Resource Pressure
# ==============================================================================

bg_grey "#Resource Pressure (PSI avg10)"
bg_blue 'PSI: CPU/Memory/I/O 자원 부족으로 작업이 대기한 비율을 표시'

show_psi

echo


# ==============================================================================
# Memory / Swap
# ==============================================================================

bg_grey "#Memory / Swap"

free -h | awk '
    /^Mem:/ {
        printf "Mem  : Total:%-8s Used:%-8s Free:%-8s Buff/Cache:%-8s Available:%s\n",
            $2, $3, $4, $6, $7
    }

    /^Swap:/ {
        printf "Swap : Total:%-8s Used:%-8s Free:%s\n",
            $2, $3, $4
    }
'


read -r _ total used mem_free shared buff_cache available \
    <<< "$(free -m | awk '/^Mem:/ {print}')"


if [[ -n "$total" && "$total" -gt 0 ]]; then

    use_per=$(awk \
        -v total="$total" \
        -v available="$available" \
        'BEGIN {
            printf "%.2f", (total - available) / total * 100
        }'
    )

    bg_blue "*Memory Usage : ${use_per}%"
fi

echo


# ==============================================================================
# Disk
# ==============================================================================

bg_grey "#Disk Usage"

df -Th \
    -x tmpfs \
    -x devtmpfs \
    -x overlay \
    -x squashfs \
    | grep -v '^/dev/loop'

echo


# ==============================================================================
# Network
# ==============================================================================

bg_grey "#Network Socket"

if command -v ss >/dev/null 2>&1; then

    ss -s | awk '
        /^Total:/ {
            printf "Socket Total: %s", $2
        }

        /^TCP:/ {
            printf "  |  %s\n", $0
        }
    '

else
    echo "ss command not found."
fi

echo


# ==============================================================================
# Top 5 CPU Processes
# ==============================================================================

bg_grey "#Top 5 Process by CPU (>= 1%)"

printf "%-10s %-7s %6s %6s  %s\n" \
    "USER" "PID" "%CPU" "%MEM" "COMMAND"

ps aux --sort=-%cpu | awk '
    NR > 1 && $3 >= 1.0 && count < 5 {

        printf "%-10s %-7s %6s %6s  ", \
            $1, $2, $3, $4

        for (i=11; i<=NF; i++) {
            printf "%s%s", $i, (i<NF ? " " : "")
        }

        printf "\n"

        count++
    }
'

echo


# ==============================================================================
# Top 5 Memory Processes
# ==============================================================================

bg_grey "#Top 5 Process by Memory (>= 1%)"

printf "%-10s %-7s %6s %6s  %s\n" \
    "USER" "PID" "%CPU" "%MEM" "COMMAND"

ps aux --sort=-%mem | awk '
    NR > 1 && $4 >= 1.0 && count < 5 {

        printf "%-10s %-7s %6s %6s  ", \
            $1, $2, $3, $4

        for (i=11; i<=NF; i++) {
            printf "%s%s", $i, (i<NF ? " " : "")
        }

        printf "\n"

        count++
    }
'

echo
