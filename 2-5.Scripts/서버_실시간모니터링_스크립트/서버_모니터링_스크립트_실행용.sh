#!/bin/bash
os=$(cat /etc/*release* | grep PRETTY_NAME | gawk -F"=" '{print $2}' |sed 's/\"//g' | gawk '{print $1}')

if [ $os = 'Ubuntu' ]; then 
    watch --color -n 2 bash server_mon_org.sh
else
    watch --color -n 2 sh server_mon_org.sh
fi