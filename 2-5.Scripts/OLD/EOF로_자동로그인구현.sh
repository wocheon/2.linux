#!/bin/bash
# CentOS에서는 정상실행되나 Ubuntu에서는 오류 발생
pass="rootpasswd"
su - << EOF
${pass}
pwd
whoami
EOF