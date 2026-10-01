#!/bin/bash

# fzf preview panel을 사용한 Bastion SSH 접속 스크립트

CURRENT_USER=$(id -un)
LIST_FILE=${BASTION_SSH_LIST_FILE:-/usr/share/bastion_ssh_connect_list.txt}

if [ "$CURRENT_USER" = 'root' ]; then
    echo "Root User 사용불가"
    exit 1
fi

if [ ! -r "$LIST_FILE" ]; then
    echo "서버 목록 파일을 읽을 수 없습니다: $LIST_FILE" >&2
    exit 1
fi

for required_command in column fzf sshpass ssh; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
        echo "필수 명령어가 없습니다: $required_command" >&2
        exit 1
    fi
done

# 목록을 먼저 저장한 뒤 각 컬럼의 최대 너비를 계산한다.
SERVER_TYPES=()
SERVER_NAMES=()
SERVER_IPS=()
SERVER_ZONES=()
SERVER_MACHINE_TYPES=()
SERVER_VCPUS=()
SERVER_MEMORY=()

while IFS=',' read -r account server_type server_name ip zone machine_type vcpus memory \
    || [ -n "${account:-}" ]; do
    memory=${memory%$'\r'}

    if [ -z "$account" ] || [[ "$account" == \#* ]]; then
        continue
    fi

    if [ "$account" = "$CURRENT_USER" ]; then
        SERVER_TYPES+=("$server_type")
        SERVER_NAMES+=("$server_name")
        SERVER_IPS+=("$ip")
        SERVER_ZONES+=("$zone")
        SERVER_MACHINE_TYPES+=("$machine_type")
        SERVER_VCPUS+=("$vcpus")
        SERVER_MEMORY+=("$memory")
    fi
done < "$LIST_FILE"

if [ "${#SERVER_NAMES[@]}" -eq 0 ]; then
    echo "$CURRENT_USER 계정에 대한 서버 목록이 없습니다."
    exit 1
fi

# 첫 번째 필드는 왼쪽에 보여줄 요약이고, 나머지 필드는 상세 패널과 SSH 접속에 사용한다.
OPTIONS=()

# column으로 한글의 터미널 표시 너비까지 반영해 표시용 행을 정렬한다.
mapfile -t DISPLAY_ROWS < <(
    {
        printf 'TYPE\tVM\tIP\n'
        for index in "${!SERVER_NAMES[@]}"; do
            printf '%s\t%s\t%s\n' \
                "${SERVER_TYPES[$index]}" \
                "${SERVER_NAMES[$index]}" \
                "${SERVER_IPS[$index]}"
        done
    } | column -t -s $'\t'
)

LIST_HEADER=${DISPLAY_ROWS[0]}
LIST_HEADER=$'\033[1;36m'"$LIST_HEADER"$'\033[0m'

for index in "${!SERVER_NAMES[@]}"; do
    display=${DISPLAY_ROWS[$((index + 1))]}

    OPTIONS+=(
        "$display"$'\t'"${SERVER_TYPES[$index]}"$'\t'"${SERVER_NAMES[$index]}"$'\t'"${SERVER_IPS[$index]}"$'\t'"${SERVER_ZONES[$index]}"$'\t'"${SERVER_MACHINE_TYPES[$index]}"$'\t'"${SERVER_VCPUS[$index]}"$'\t'"${SERVER_MEMORY[$index]}"
    )
done

TITLE_TEXT=$'\033[44;37m Bastion SSH \033[0m'
HEADER=$(printf '\033[1;32m* User : %s\033[0m\n\033[1;33m* VMs  : %d\033[0m\n\n\033[1;36mENTER\033[0m: SSH  \033[1;31mESC\033[0m: Cancel' \
    "$CURRENT_USER" "${#OPTIONS[@]}")

# 최근 fzf에서는 외곽 제목과 반응형 preview를 사용하고,
# 구버전에서는 지원하는 범위 내에서 기본 UI로 실행한다.
FZF_HELP=$(fzf --help 2>/dev/null)
PREVIEW_WINDOW='right:42%'

if [[ "$FZF_HELP" == *'SIZE_THRESHOLD'* ]]; then
    PREVIEW_WINDOW='right,42%,border-left,<100(down,40%,border-top)'
fi

if [[ "$FZF_HELP" != *'--border-label'* ]]; then
    HEADER="$TITLE_TEXT"$'\n'"$HEADER"
fi

FZF_OPTIONS=(
    --delimiter=$'\t'
    --with-nth=1
    --height=60%
    --reverse
    --ansi
    --border
    --prompt='VM > '
    --select-1
    --header-lines=1
    "--header=$HEADER"
    "--preview-window=$PREVIEW_WINDOW"
    '--preview=printf "\033[44;37m VM Info \033[0m\n\033[36m────────────────────────\033[0m\n\n\033[1;36mVM\033[0m      : %s\n\033[1;36mIP\033[0m      : %s\n\033[1;36mZONE\033[0m    : %s\n\033[1;36mTYPE\033[0m    : %s\n\033[1;36mvCPU\033[0m    : %s\n\033[1;36mMemory\033[0m  : %s GB\n" {3} {4} {5} {6} {7} {8}'
)

if [[ "$FZF_HELP" == *'--info'* ]]; then
    FZF_OPTIONS+=(--info=hidden)
fi

if [[ "$FZF_HELP" == *'--pointer'* ]]; then
    FZF_OPTIONS+=(--pointer='▶')
fi

if [[ "$FZF_HELP" == *'--color'* ]]; then
    FZF_OPTIONS+=(--color='border:240,pointer:42,prompt:39,header:245,hl:220,hl+:220')
fi

if [[ "$FZF_HELP" == *'--border-label'* ]]; then
    FZF_OPTIONS+=("--border-label=$TITLE_TEXT" --border-label-pos=2)
fi

if [[ "$FZF_HELP" == *'--header-first'* ]]; then
    FZF_OPTIONS+=(--header-first)
fi

if [[ "$FZF_HELP" == *'--highlight-line'* ]]; then
    FZF_OPTIONS+=(--highlight-line)
fi

if [[ "$FZF_HELP" == *'--gutter'* ]]; then
    FZF_OPTIONS+=(--gutter=' ')
fi

if [[ "$FZF_HELP" == *'--no-scrollbar'* ]]; then
    FZF_OPTIONS+=(--no-scrollbar)
fi

CHOICE=$(
    {
        printf '%s\n' "$LIST_HEADER"
        printf '%s\n' "${OPTIONS[@]}"
    } | fzf "${FZF_OPTIONS[@]}"
)
FZF_STATUS=$?

if [ "$FZF_STATUS" -eq 1 ] || [ "$FZF_STATUS" -eq 130 ]; then
    echo "취소되었습니다."
    exit 0
elif [ "$FZF_STATUS" -ne 0 ]; then
    echo "fzf 실행 중 오류가 발생했습니다. (exit: $FZF_STATUS)" >&2
    exit "$FZF_STATUS"
fi

if [ -z "$CHOICE" ]; then
    echo "취소되었습니다."
    exit 0
fi

IFS=$'\t' read -r display server_type server_name ip zone vm_machine_type vcpus memory \
    <<< "$CHOICE"

printf '\033[35m* Selected_VM : %s (%s) - %s\n  Machine_Type : %s (%s,%s)\033[0m\n' \
    "$server_name" "$ip" "$zone" "$vm_machine_type" "$vcpus" "$memory"

sshpass ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "$CURRENT_USER@$ip"
