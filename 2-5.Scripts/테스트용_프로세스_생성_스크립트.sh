#!/bin/bash
# orphan.sh - 고아 프로세스 생성 테스트

# 자식 프로세스를 백그라운드에서 실행
(
  echo "자식 PID: $$ - 20초간 실행"
  sleep 20
  echo "자식 프로세스 종료"
) &

echo "부모 PID: $$ - 바로 종료합니다"
exit 0

#!/bin/bash
# zombie.sh

echo "부모 PID: $$"
(
    # 자식 프로세스
    echo "자식 프로세스 PID: $$ (곧 종료)"
    exit 0
) &
# 자식 종료 후 부모가 wait 하지 않고 대기
sleep 60
