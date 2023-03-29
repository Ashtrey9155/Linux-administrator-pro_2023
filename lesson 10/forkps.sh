#!/bin/bash
#IFS=$’\n’
. ./getCommandName.sh
. ./getTTY.sh
. ./getTotalCpu.sh
. ./getStat.sh

pids=$(	find /proc -maxdepth 1 -regex ".*[0-9]" | sed 's/\/proc\///' )
res=''
for pid in $pids
	do
		res+=$(echo "$pid | $(getTTY $pid) | $(getStat $pid) | $(getCpu $pid) | $(getCommand $pid)) '")
	done
echo $res |  sed "s/'/\n/g"  | column -s '|' -t --table-columns PID,TTY,STAT,TIME,COMMAND | cut -c1-$(tput cols)
