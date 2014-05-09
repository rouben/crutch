#!/bin/sh
SERVICES="bfgminer cgminer cpuminer"
OUTDIR="/run/shm/"
LOGFILE=$OUTDIR"crutch.log"
BINDIR="/usr/local/bin/"

###############################################

for SERVICE in $SERVICES
do
  pgrep $SERVICE > /dev/null 2> /dev/null
  TEST_RESULT=$?
  if [ "${TEST_RESULT}" -ne "0" ]
  then
    echo "$(date +'%Y-%m-%d %T %Z'): $SERVICE is not running" >> $LOGFILE
    screen -dmS $SERVICE $BINDIR$SERVICE
    echo "Restarted $SERVICE at $(date +'%Y-%m-%d %T %Z')..." > $OUTDIR$SERVICE.status
  else
    screen -S $SERVICE -p 0 -X hardcopy $OUTDIR$SERVICE.status
  fi
done
