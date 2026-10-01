#!/bin/bash

# 현재 접속한 사용자 계정명 읽기
USER=$(whoami)
if [ "$USER" == 'root' ]; then
    echo "Root User 사용불가"
    exit 1
fi

# 실행중인 서버 목록을 OPTIONS 배열에 저장
OPTIONS=("구분 서버명 IP ZONE Machine_Type (vCPUs,Memory)")

# 서버 목록 파일 읽기
while IFS=',' read -r account server_type server_name ip zone machine_type vcpus memory; do
    # 빈 줄과 주석은 제외
    if [ -z "$account" ] || [[ "$account" == \#* ]]; then
        continue
    fi

    if [ "$account" == "$USER" ]; then
        # 각 항목을 공백으로 구분하여 저장
        OPTIONS+=("$server_type $server_name $ip $zone $machine_type ($vcpus,$memory) ")
    fi
done < /usr/share/bastion_ssh_connect_list.txt

# 헤더 외에 서버 목록이 없으면 종료
if [ "${#OPTIONS[@]}" -eq 1 ]; then
    echo "$USER 계정에 대한 서버 목록이 없습니다."
    exit 1
fi


# 타이틀 출력
echo -e "\E[44;37m### Bastion SSH 접속###\E[0m"
echo -e "\E[;32m* User : $USER\E[0m"

# fzf를 사용하여 서버 선택 (커서가 맨 위에 가도록 --reverse 옵션 추가)
CHOICE=$((
#    echo "$HEADER"
    for option in "${OPTIONS[@]}"; do
        echo "$option"
    done
) | column -t | fzf --reverse --prompt="검색: " --header-lines=1 --height=60% --border --ansi --select-1)

# 선택된 값 확인 및 처리
if [ -n "$CHOICE" ]; then
    # 선택된 항목에서 서버 정보를 추출
    SERVER_INFO=$(echo "$CHOICE" | awk '{print $3}' | xargs)
    SELECTED=$(awk -F',' -v user="$USER" -v ip="$SERVER_INFO" \
        '$1 == user && $4 == ip { print; exit }' \
        /usr/share/bastion_ssh_connect_list.txt)

    if [ -n "$SELECTED" ]; then
        # 선택한 서버 정보 분리
        IFS=',' read -r account server_type server_name ip zone vm_machine_type vcpus memory <<<"$SELECTED"
        echo -e "\E[;35m* Selected_VM : $server_name ($ip) - $zone \n  Machine_Type : ${vm_machine_type} (${vcpus},${memory})\E[0m"
        sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$ip"
    else
        echo "유효하지 않은 선택입니다."
    fi
else
    echo "취소되었습니다."
fi
