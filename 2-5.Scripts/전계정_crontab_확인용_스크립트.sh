#!/bin/bash
# 모든 사용자의 crontab 확인 스크립트
# Root 권한으로 실행 필요
for user in $(grep /bin/bash /etc/passwd | cut -f1 -d:);
do
        echo $user; crontab -u $user -l;
done
