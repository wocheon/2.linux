#!/bin/bash

script_path=$1

if [ -z "$script_path" ]; then
    echo "Usage: $0 <script_path>"
    exit 1
fi
pass='test123' # 로컬 테스트용 임의 비밀번호

expect << EOF
spawn su 
expect "Password:"
sleep 1
send "$pass\n"
send "sh $script_path; exit;\n"
expect eof
EOF

exit
