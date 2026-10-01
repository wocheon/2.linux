#!/bin/bash
time=$(date '+%Y%m%d%H%M')
branch=$(git branch --show-current)
remote=$(git config --get "branch.${branch}.remote")
remote=${remote:-origin}

if [ -z "$branch" ]; then
	echo "현재 브랜치를 확인할 수 없습니다."
	exit 1
fi

git add .

if [ $? -eq 0 ]; then
	echo -e "\E[42;37mADD : OK\E[0m"
else 
	echo -e "\E[41;37mADD : FAIL\E[0m"
	exit
fi

git commit -m "$time"

if [ $? -eq 0 ]; then
	echo -e "\E[42;37mCOMMIT : OK\E[0m"
else 
	echo -e "\E[41;37mCOMMIT : FAIL\E[0m"
	exit
fi

git push "$remote" "$branch"

if [ $? -eq 0 ]; then
	echo -e "\E[42;37mPUSH : OK\E[0m"
else 
	echo -e "\E[41;37mPUSH : FAIL\E[0m"
	exit
fi
