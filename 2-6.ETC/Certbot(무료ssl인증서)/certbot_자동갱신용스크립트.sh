#!/bin/bash
# 매월 마지막주 일요일 오전 4시에 실행.
# 0 4 * * 0 [ $(date +"\%m") -ne $(date -d 7days +"\%m") ] && sh /etc/haproxy/cerbot_renew.sh
# log_path 디렉토리 생성확인 후 진행.

today_date=$(date '+%y%m%d')
log_path='/var/log/letsencrypt/ssl_renew_log'
mkdir -p $log_path

log_file=$log_path/cert_renew_log_${today_date}.log
dup_chck=$(find $log_path -name cert_renew_log_$today_date* | wc -l)

if [ $dup_chck -ne 0 ]; then
        file_num=`expr $dup_chck + 1`
        mv $log_file $log_path/cert_renew_log_${today_date}_${file_num}.log
fi

exec > $log_file

echo  "##JOB Start##"
echo "StartDate : " $(date) 
echo "LogFile : ${log_file}"  
echo "" 


echo  "##Certificate Info##"
certbot certificates 
echo "" 

domain=$(tail -5 /var/log/letsencrypt/letsencrypt.log | grep Domains: | gawk -F': ' '{print $2}')
expiry_date=$(tail -5 /var/log/letsencrypt/letsencrypt.log | grep VALID: | gawk -F'VALID: ' '{print $2}' | gawk '{print $1}')

if [ $expiry_date -gt 30 ]; then
        echo "*Expiry Date : ${expiry_date} Days Remain"
        echo "Renew Certificates Canceled"
#        rm -f $log_file
        exit
fi

echo  "##Port 80 Open Check##"
port_chck=$( netstat -ntlp | grep -w '0.0.0.0.0:80' | wc -l)

if [ $port_chck -ne 0 ]; then
        process=$(netstat -tnlp | grep -w '0.0.0.0.0:80' | gawk '{print $7}' | gawk -F'/' '{print $2}')
        echo "Port 80 Used by $process" 
        echo "" 

        echo  "##Renew Certificate##"
        echo "systemctl stop haproxy"
        systemctl stop haproxy

        certbot renew  
#       certbot renew --force-renewal 

        echo "systemctl start haproxy"
        systemctl start haproxy
else
        echo "Port 80 Usable" 
        echo "" 
        echo  "##Renew Certificate##"
        certbot renew  
#       certbot renew --force-renewal 

fi

echo "" 
echo  "##Certificate Info##"
certbot certificates 


certpath="/etc/letsencrypt/live/${domain}/"
cat ${certpath}cert.pem > ${certpath}site.pem
cat ${certpath}chain.pem >> ${certpath}site.pem
cat ${certpath}privkey.pem >> ${certpath}site.pem


echo "" 
echo "##JOB Finished##"
