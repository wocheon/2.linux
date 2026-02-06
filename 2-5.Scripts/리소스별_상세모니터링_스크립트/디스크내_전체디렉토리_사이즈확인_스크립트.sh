#!/bin/bash

# 현재 디스크 사용량 확인 
echo "# Check Disk Usage"
df -Th | grep ^\/dev | grep -v snap

# 전체 디렉토리 별 용량 확인  (/share , /proc 디렉토리는 검색대상에서 제외)
echo "# Check disk usage by directory (exclude /share, /proc)"
du -sh --exclude=/share --exclude=/proc /* | sort -rh

# 가장 사이즈가 큰 10개 파일 목록 출력 ( /share , /proc 디렉토리는 검색대상에서 제외)
echo "# List the top 10 largest files (exclude /share, /proc)"
find / -path /share -prune -o -path /proc -prune -o -type f -exec du -h {} + | sort -rh | head -n 10
