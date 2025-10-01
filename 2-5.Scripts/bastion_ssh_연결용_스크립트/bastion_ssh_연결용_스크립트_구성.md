# Bastion ssh 접속용 fzf 스크립트

## 필수 패키지 설치 

- fzf , sshpass 설치 
```bash
sudo apt update
sudo apt install -y fzf
sudo apt install -y sshpass
```

## options_user.txt 형식 
- 사용자명,서버구분,서버명,IP,서버상태
> ex) 
```
user1,web/was,server-1,10.0.0.100,RUNNING
user1,web/was,server-2,10.0.0.200,RUNNING
```

## 스크립트 구성 

```bash
#!/bin/bash
# 현재 접속한 사용자 계정명 읽기
USER=$(whoami)

# 실행중인 서버 목록을 OPTIONS 배열에 저장
OPTIONS=()

# options_user.txt 파일 읽기
while IFS=',' read -r account server_type server_name ip status; do
    if [ "$account" == "$USER" ]; then
        # 각 항목을 공백으로 구분하여 저장
        OPTIONS+=("$server_type $server_name $ip $status")
    fi
done < options_user.txt

# 실행중인 서버 목록이 없으면 종료
if [ ${#OPTIONS[@]} -eq 0 ]; then
    echo "$USER 계정에 대한 서버 목록이 없습니다."
    exit 1
fi

# 헤더 출력 형식
HEADER=$(printf "%-12s %-33s %-12s %-10s\n" "구분" "서버명" "IP" "상태")

# 타이틀 출력
echo "=============================="
echo "   Bastion SSH 접속"
echo "   USER : $USER"
echo "=============================="

# 헤더 출력 후 서버 목록을 fzf로 선택
CHOICE=$((    
    for option in "${OPTIONS[@]}"; do
        echo "$option"
    done
) | column -t | fzf --reverse --prompt="검색: " --header="$HEADER" \
	--height=60% --border --ansi --select-1)

# 선택된 값 확인 및 처리
if [ -n "$CHOICE" ]; then
    # 선택된 항목에서 서버 정보를 추출 - IP기준 
    SERVER_INFO=$(echo "$CHOICE" | awk '{print $3}' | xargs)
    SELECTED=$(grep "$SERVER_INFO" options_user.txt | head -n 1)

    if [ -n "$SELECTED" ]; then
        # 서버 정보 분리 (server_type, server_name, ip, status)
        IFS=',' read -r account server_type server_name ip status <<<"$SELECTED"

        # SSH 접속을 위한 패스워드 입력
        read -sp "서버 $server_name ($ip)에 접속할 패스워드를 입력하세요: " PASSWORD
        echo

        if [ -n "$PASSWORD" ]; then
            echo "접속 중: $ip (계정: $USER)"
            # SSH 접속 명령 실행 (패스워드 입력을 자동으로 처리하려면 sshpass 사용 필요)
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$ip"
        else
            echo "패스워드가 입력되지 않았습니다. 접속을 취소합니다."
        fi
    else
        echo "유효하지 않은 선택입니다."
    fi
else
    echo "취소되었습니다."
fi
```

## GCP VM용 Bastion Script

- 계정 별 서버 목록 파일
    - 각 계정별 접근 가능 VM 목록 기록 
    - ID/구분/VM명/IP/ZONE/Machine_Type/CPU/Memory 순으로 기록 
> /usr/share/bastion_ssh_connect_list.txt
```
#user1
user1,PROD,vm-1,192.168.1.110,asia-northeast3-a,n1-standard-2,2,8
user1,PROD,vm-2,192.168.1.120,asia-northeast3-a,n1-standard-2,2,8
#user2
user2,PROD,vm-2,192.168.1.120,asia-northeast3-a,n1-standard-2,2,8
user2,PROD,vm-3,192.168.1.130,asia-northeast3-a,n1-standard-8,8,32
```

- fzf 실행용 bastion 스크립트 
    - /usr/local/bin에 생성하여 바로 실행가능하도록 설정
    - 755 권한 부여 
> /usr/local/bin/bastion_ssh_connect 
```bash
#!/bin/bash

# 현재 접속한 사용자 계정명 읽기
USER=$(whoami)
if [ $USER == 'root' ];then
    echo "Root User 사용불가"
        exit 0
fi

# 실행중인 서버 목록을 OPTIONS 배열에 저장
OPTIONS=()
first_line=true

# options_user.txt 파일 읽기
while IFS=',' read -r account server_type server_name ip zone machine_type vcpus memory; do
        if $first_line; then
        # 헤더를 그대로 추가
        OPTIONS+=("구분 서버명 IP ZONE Machine_Type (vCPUs,Memory)")
        first_line=false
        continue
    fi

    if [ "$account" == "$USER" ]; then
        # 각 항목을 공백으로 구분하여 저장
        OPTIONS+=("$server_type $server_name $ip $zone $machine_type ($vcpus,$memory) ")
    fi
done < /usr/share/bastion_ssh_connect_list.txt

# 실행중인 서버 목록이 없으면 종료
if [ ${#OPTIONS[@]} -eq 0 ]; then
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
    SELECTED=$(grep -w "$SERVER_INFO" /usr/share/bastion_ssh_connect_list.txt | head -n 1)

    if [ -n "$SELECTED" ]; then
        # 서버 정보 분리 (server_type, server_name, ip, status)
        IFS=',' read -r account server_type server_name ip zone vm_machine_type specs <<<"$SELECTED"
                echo -e "\E[;35m* Selected_VM : $server_name ($ip) - $zone \n  Machine_Type : ${vm_machine_type} (${specs})\E[0m"
        sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$ip"
    else
        echo "유효하지 않은 선택입니다."
    fi
else
    echo "취소되었습니다."
fi
```

