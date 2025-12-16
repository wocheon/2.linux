#!/bin/bash

# netstat -tnlp 실행하고 첫 번째 줄을 건너뛰기
echo -e "Proto\t\tLocal Address\t\tState\t\tPID\tProgram name\t\tCMD"  # 헤더 출력
netstat -tnlp | tail -n +2 | while read line; do
  # netstat의 PID/Program name 열 추출
  pid_program=$(echo $line | awk '{print $7}')

  # PID만 추출 (숫자만 추출, 슬래시 뒤의 프로그램 이름은 제외)
  pid=$(echo $pid_program | sed 's/\/.*//')

  # PID가 숫자인지 확인 (유효한 PID인지 체크)
  if [[ "$pid" =~ ^[0-9]+$ ]]; then
    # 프로그램 이름 추출
    program=$(echo $pid_program | sed 's/^[0-9]*\///')

    # ps 명령을 통해 해당 PID의 CMD 값 가져오기
    cmd=$(ps -p $pid -o cmd=)

    # netstat의 나머지 정보 추출
    proto=$(echo $line | awk '{print $1}')
    local_address=$(echo $line | awk '{print $4}')
    state=$(echo $line | awk '{print $6}')

    # 결과 출력 (각 항목을 탭으로 정렬하여 출력)
    printf "%-8s\t%-22s\t%-15s\t%-5s\t%-15s\t%s\n" "$proto" "$local_address" "$state" "$pid" "$program" "$cmd"
  fi
done
