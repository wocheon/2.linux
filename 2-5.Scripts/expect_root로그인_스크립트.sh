#!/bin/bash

script_path=$1

ip=$(hostname -i | gawk '{print $1}')
host_nm=$(hostname | gawk -F'_' '{print $1}')

if [ $host_nm == 'test' ] || [ $host_nm = 'dev' ]; then
    pass="welcome1"
else
     pass="prod$(hostname -i | gawk '{print $1}' | gawk -F'.' '{print $4}')"
fi

expect << EOF
spawn su 
expect "Password:"
sleep 1
send "$pass\n"
send "sh $script_path; exit;\n"
expect eof
EOF

exit