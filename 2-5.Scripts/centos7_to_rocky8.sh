#!/bin/bash
# CentOS 7.9  TO Rocky Linux 8
centos_v=$(cat /etc/centos-release | gawk '{print $4}' | gawk -F'.' '{print $2}' )

if [ $centos_v -lt 9 ]; then
        yum update -y
		exit       
fi

sudo yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el7.noarch.rpm

sudo yum install -y leapp-upgrade leapp-data-rocky
 
sudo leapp preupgrade

echo PermitRootLogin yes | sudo tee -a /etc/ssh/sshd_config
sudo leapp answer --section remove_pam_pkcs11_module_check.confirm=True


sudo leapp upgrade

