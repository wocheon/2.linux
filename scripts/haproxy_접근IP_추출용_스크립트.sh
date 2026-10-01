#!/bin/bash

## HAProxy 접근IP_추출용_스크립트.sh ##
# HAProxy 로그파일에서 특정 키워드(예: Solr 접근 관련)를 포함하는
# 로그들을 추출하고, IP별/HTTP_CODE별로 접속 횟수를
# 집계하여 별도의 로그파일로 저장하는 스크립트

# check Using Solr HAProxy VM's IP
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
yesterday_YMD=$(date '+%Y%m%d')

# log_path="/var/log/haproxy"
# log_file="haproxy_0.log-$yesterday_YMD"
HOSTNAME=$(hostname)

log_keyword="KEYWORD"

#haproxy_log용 디렉토리 없으면 생성
mkdir -p $SCRIPT_DIR/haproxy_logs

#기존 파일 삭제
rm -rf $SCRIPT_DIR/haproxy_logs/*

# haproxy_0.log 전체 복사
cp /var/log/haproxy/haproxy_0.log* $SCRIPT_DIR/haproxy_logs

# gz 파일 압축 해제
cd $SCRIPT_DIR/haproxy_logs
gzip -d haproxy_0.log*.gz

# 전체 로그파일 내에서 키워드 포함 로그 추출
grep -rh $log_keyword ./* > haproxy_0_grep_keyword.log

#작업 후 기존 디렉토리로 이동
cd $SCRPIT_DIR

# IP/HTTP_CODE 별 로그 Count 추출
awk '{split($6, a, ":"); print a[1], $11}' $SCRIPT_DIR/haproxy_logs/haproxy_0_grep_keyword.log | sort | uniq -c | sort -nr | awk -v host="$HOSTNAME" '{print host, $2, $3, $1}' > $SCRIPT_DIR/haproxy_acl_$(hostname)_$yesterday_YMD.log