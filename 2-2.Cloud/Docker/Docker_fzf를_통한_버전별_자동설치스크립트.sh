#!/bin/bash

# fzf를 통한 docker 버전별 설치 스크립트 
# bash로 실행 필요 

#도커 설치에 필요한 패키지 다운로드
sudo apt update -y
sudo apt install -y fzf  #fzf
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# 도커 공식 GPG key 등록
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 도커 Repository 설정
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 설치가능한 docker 버전확인
apt list -a docker-ce  | awk 'NR>1 {print $1 "," $2 "," $3}' > docker_version_list.txt

# docker_version_list.txt 파일을 읽어서 배열로 저장
while IFS=',' read -r package_name version platform; do
        # 각 항목을 공백으로 구분하여 저장
        OPTIONS+=("$package_name $version $platform")
done < docker_version_list.txt

HEADER=$(printf "%-19s %-32s %-12s\n" "패키지" "버전" "Platform" )

echo "# 설치할 docker 버전 선택"

# fzf로선택창 출력
CHOICE=$((
    for option in "${OPTIONS[@]}"; do
        echo "$option"
    done
    ) | column -t | fzf --reverse --prompt="검색: " --header="$HEADER" \
        --height=60% --border --ansi --select-1)

if [ -n "$CHOICE" ]; then
        choice_package_version=$(echo $CHOICE | gawk '{print $2}' | xargs)
        choice_docker_version=$(echo $choice_package_version | gawk -F':' '{print $2}' |  gawk -F'~' '{print $1}')

        echo "Install Docker Version : $choice_docker_version"
else
        echo "No choice"
        exit 0
fi

echo "# apt install -y docker-ce=$choice_package_version docker-ce-cli=$choice_package_version containerd.io"

# 선택한 버전 설치
apt install -y docker-ce=${choice_package_version} docker-ce-cli=${choice_package_version} containerd.io

rm -rf docker_version_list.txt

systmectl status docker 

docker --version