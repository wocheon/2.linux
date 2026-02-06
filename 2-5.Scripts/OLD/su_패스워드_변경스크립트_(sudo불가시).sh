#!/bin/bash
######################################################
# -Example											 #
#	sh passwd_change.sh [root_pass] [user] [passwd]  #
######################################################

os=$(cat /etc/*release* | grep ^ID= | gawk -F "=" '{print $2}' | tr -d '"')
user=$2
pass=$3
rootpass=$1

if [ $os == 'ubuntu' ]; then 
	chpass='/usr/bin/chpasswd'
else
	chpass='/sbin/chpasswd'
fi

su - root -c "echo '${user}:${pass}' | ${chpass} " << EOF 
${rootpass}
EOF
