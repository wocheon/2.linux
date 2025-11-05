#!/bin/bash
# CentOS 7.9  TO Rocky Linux 8

# CentOS 버전의 소수점을 분리하여 뽑아냅니다. 
# (7.9 -> 9 추출) - 7.x 중 7.9인지 확인 목적
centos_v=$(cat /etc/centos-release | gawk '{print $4}' | gawk -F'.' '{print $2}' )

# CentOS 7.x 중 7.9 이전 버전이면 업데이트 후 스크립트 종료
if [ $centos_v -lt 9 ]; then
        yum update -y           # 기본 패키지 모두 최신 버전으로 업데이트
		exit                  # 스크립트 종료 (7.9 이하 버전 업그레이드 권장)
fi

# AlmaLinux(ELevate 프로젝트)의 패키지 저장소 RPM 설치
# 이 저장소 내에 마이그레이션 관련 툴(leapp 등)이 포함됨
sudo yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el7.noarch.rpm

# ELevate 프로젝트 기반의 리눅스 업그레이드 도구인 leapp 설치
sudo yum install -y leapp-upgrade leapp-data-rocky

# leapp을 사용하여 업그레이드 전 사전검사(시스템 호환성, 의존성 등 확인)
sudo leapp preupgrade

# root SSH 접속 허용 설정 추가 (마이그레이드 중 필요할 수 있음)
echo PermitRootLogin yes | sudo tee -a /etc/ssh/sshd_config

# leapp에서 "remove_pam_pkcs11_module_check.confirm=True" 옵션을 자동으로 승인
# 이 옵션은 보통 업그레이드 중 PAM PKCS#11 모듈 제거 동의를 의미
sudo leapp answer --section remove_pam_pkcs11_module_check.confirm=True

# 본격 업그레이드 명령 실행 (CentOS 7 -> Rocky Linux 8 실제 마이그레이션 진행)
sudo leapp upgrade