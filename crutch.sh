#!/bin/bash
cd /home/rouben
SERVICES=( "bfgminer" "cgminer" "cpuminer" )
#SERVICES=( "bfgminer" )
for SERVICE in "${SERVICES[@]}"
do
  #echo "Checking ${SERVICE}..."
  pgrep $SERVICE &> /dev/null
  result=$?
  #echo "exit code: ${result}"
  if [ "${result}" -ne "0" ] ; then
    echo "`date`: $SERVICE is not running" >> /home/rouben/crutch.log
    screen -dmS $SERVICE /usr/local/bin/$SERVICE
  fi
done
