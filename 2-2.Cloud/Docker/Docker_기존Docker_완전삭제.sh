#!/bin/bash

# Ubuntu 20.04 기준

# docker 관련 패키지 전체 삭제
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# docker 데이터 및 디렉토리 삭제
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker

# 의존성 삭제
sudo apt-get autoremove -y

# GPG 키 삭제
sudo apt-key del $(sudo apt-key list | grep Docker | awk '{print $2}')

# 삭제 확인
docker --version
sudo systemctl status docker