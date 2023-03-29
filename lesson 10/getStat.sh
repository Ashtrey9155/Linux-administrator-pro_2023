#!/bin/bash
function getStat {
	PID=$1

	cmdline=$( cat /proc/$PID/cmdline 2>/dev/null | sed -e "s/\x00/ /g")

	if [ "$PID" ]; then
		statusName="$( cat /proc/$PID/status 2>/dev/null | grep State | awk '{print $2}')"
	fi
	echo  $statusName
}
