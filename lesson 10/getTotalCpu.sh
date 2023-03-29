#!/bin/bash
function getCpu {
  PID=$1
  if [ -z "$PID" ]; then
      echo Usage: $0 PID
      exit 1
  fi

  PROCESS_STAT=($(sed -E 's/\([^)]+\)/X/' "/proc/$PID/stat" 2>/dev/null))

  if [[ -z "$PROCESS_STAT" ]]; then
          exit 1
  fi
  PROCESS_UTIME=${PROCESS_STAT[13]}
  PROCESS_STIME=${PROCESS_STAT[14]}
  PROCESS_STARTTIME=${PROCESS_STAT[21]}
  SYSTEM_UPTIME_SEC=$(tr . ' ' </proc/uptime | awk '{print $1}')

  CLK_TCK=$(getconf CLK_TCK)


  if [[ $PROCESS_UTIME = '' ]]; then
          echo '0:00'
          exit 1
  fi

  let PROCESS_UTIME_SEC="$PROCESS_UTIME / $CLK_TCK"
  let PROCESS_STIME_SEC="$PROCESS_STIME / $CLK_TCK"


  let PROCESS_USAGE_SEC="$PROCESS_UTIME_SEC + $PROCESS_STIME_SEC"

  function convertTime {
    let "hh = $1 / 60"
    mm=$(($1%60))
    if (( "$mm" < 10 )); then 
      mm="0${mm}" 
    fi

    result="${hh}:${mm}"
    echo $result
  }

  echo $( convertTime ${PROCESS_USAGE_SEC} )
}
