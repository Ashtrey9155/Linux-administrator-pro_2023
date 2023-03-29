#!/bin/bash
function getCommand {
	PID=$1

	cmdline=$( cat /proc/$PID/cmdline 2>/dev/null | sed -e "s/\x00/ /g")

	if [ -z "$cmdline" ]; then
		cmdline="[$( cat /proc/$PID/status 2>/dev/null | grep Name | awk '{print $2}')]"
	fi
	echo  $cmdline
}
