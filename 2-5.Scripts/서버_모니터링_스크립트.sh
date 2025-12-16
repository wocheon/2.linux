#!/bin/bash
function bg_blue (){
echo -e "\E[44;37m$1\E[0m"
}

function bg_grey (){
echo -e "\E[47;30m$1\E[0m"
}

function yellow (){
echo -e "\E[;33m$1\E[0m"
}

host_nm=$(hostname)
ip=$(hostname -i | gawk '{print $1}')
os=$(cat /etc/*release* | grep PRETTY_NAME | gawk -F"=" '{print $2}' |sed 's/\"//g' | gawk '{print $1}')

bg_grey "#Server Info"
echo "$(yellow Hostname) : $host_nm $(yellow IP) : $ip $(yellow OS) : $os"

bg_grey "#Server Spec"
echo "$(yellow vCPU) : $(grep -c processor /proc/cpuinfo) $(yellow Memory) : $(free -h | grep Mem | gawk '{print $2}')"
echo ""

bg_grey "#Uptime"
uptime
echo ""

bg_grey "#Top"
top -b -n 1 | head -5

#if [ $os = "Ubuntu" ]; then
#    bg_blue "*CPU Usage (%) : $( mpstat | tail -1 | awk '{print 100-$NF}')"
#else
    bg_blue "*CPU Usage (%) : $(top -bn2 -d 1 | grep '^%Cpu' | tail -n 1 | grep -Po '[0-9.]+(?=\s+id)' | awk '{print 100-$1}')"
#fi

#echo "#mpstat (CPU Usage Detail)"
#mpstat -P ALL
#echo ""

bg_grey "#sar (CPU Usage Detail)"
sar 1 1
echo ""

bg_grey "#Memory"
free -h
total=$(free -m | grep Mem: | awk '{print $2}')
use=$(free -m | grep Mem: | awk '{print $3}')
buff_cache=$(free -m | grep Mem: | awk '{print $6}')
avail=$(free -m | grep Mem: | awk '{print $7}')
use_per_1=$(echo "scale=2; ($total - $avail) / $total * 100" | bc)
use_per_2=$(echo "scale=2; 100 - ( $total - $use - $buff_cache ) / $total * 100" | bc)
bg_blue "Memory Usage (Total - available) (%) : $use_per_1 %"
bg_blue "Memory Usage (Total - use - buff_cache)(%) : $use_per_2 %"
echo ""

bg_grey "#Disk Usage"
df -Th | egrep -v '(tmpfs|share|/dev/loop)'
echo ""

bg_grey "#Top 10 Process Sort by Cpu Usage (More Than 1%)"
echo "USER  PID %CPU    %MEM    VSZ RSS TTY STAT    START   TIME    COMMAND"
ps -aux --sort -pcpu |head -n 11 | gawk '$3 >=1'
echo ""

bg_grey "#Top 10 Process Sort by Memory Usage (More Than 1%)"
echo "USER  PID %CPU    %MEM    VSZ RSS TTY STAT    START   TIME    COMMAND"
ps -aux --sort -rss |head -n 11 | gawk '$4 >=1'
echo ""
