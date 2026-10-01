#!/bin/bash

# Ubuntu 24.04 기준

# docker 관련 패키지 전체 삭제
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# docker 데이터 및 디렉토리 삭제
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker

# 의존성 삭제
sudo apt-get autoremove -y

# Repository 및 GPG 키 삭제
sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.sources
sudo rm -f /etc/apt/keyrings/docker.asc /etc/apt/keyrings/docker.gpg

# 삭제 확인
docker --version
sudo systemctl status docker