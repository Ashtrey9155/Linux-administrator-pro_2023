#!/bin/bash
function getTTY {
	PID=$1

        if [ -z "$PID" ]; then
                echo Usage: $0 PID
                exit 1
        fi

        getTty=$(ls -l /proc/$PID/fd/0 2> /dev/null | awk '{print $NF}')

        tty=$getTty

        if [[ $tty =~ ^anon.+$ ]];
                then
                        tty=$(echo anon)
                fi

        case $tty in
                /dev/null) tty=$(echo "?");;
                '' ) tty=$(echo "?");;
                anon ) tty=$(echo "?") ;;
                *) tty=$(echo $getTty | sed  's/\/dev\// /') ;;
        esac

        echo $tty
}
