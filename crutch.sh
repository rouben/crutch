#!/bin/sh
###############################################
# START OF CONFIG
# Space-separated list of services to monitor
# e.g. SERVICES="service1 service2"
SERVICES="bfgminer cgminer cpuminer"

# Look for these strings in the "screenshot" files for each
# respective service as a sign of that service being stunned.
# e.g. STUN_service1="detected new block" # bfg/cgminer
# e.g. STUN_service2="Dispatching new work to" # cpuminer/minerd
STUN_bfgminer="detected new block"
STUN_cgminer="detected new block"
STUN_cpuminer="Dispatching new work to"

# If the above strings indicating that the service is stunned
# occur at least this number of times, kill the service
# e.g. THR_service1="5"
# e.g. THR_service2="3"
THR_bfgminer="5"
THR_cgminer="5"
THR_cpuminer="5"

# Directory (/tmp or ramdisk) where runtime stuff like log and
# "screenshots" are stored, including trailing slash.
OUTDIR="/run/shm/"

# Full path to log file (usually $OUTDIR + log file name).
LOGFILE=$OUTDIR"crutch.log"

# Full path to where service binaries are located, including
# trailing slash.
BINDIR="/usr/local/bin/"
# END OF CONFIG
###############################################

for SERVICE in $SERVICES
do
  # Set $THR to the value of $THR_service (whichever service we're iterating)
  eval "THR=\$THR_$SERVICE"
  # Set $STUN to the value of $STUN_service (whichever service we're iterating)
  eval "STUN=\$STUN_$SERVICE"
  # Look for a running process
  pgrep $SERVICE > /dev/null 2> /dev/null
  TEST_RESULT=$?
  if [ "${TEST_RESULT}" -ne "0" ]
  then
    echo "$(date +'%Y-%m-%d %T %Z'): $SERVICE is not running" >> $LOGFILE
    screen -dmS $SERVICE $BINDIR$SERVICE
    echo "Restarted $SERVICE at $(date +'%Y-%m-%d %T %Z'), because it was down..." > $OUTDIR$SERVICE.status
  else
    if [ "$(grep "$STUN" $OUTDIR$SERVICE.status | wc -l)" -gt "$THR" ]
    then
      echo "$(date +'%Y-%m-%d %T %Z'): Found more than $THR occurrences of \"$STUN\" in $OUTDIR$SERVICE.status. $SERVICE appears to be stunned, taking action!" >> $LOGFILE
      pkill -9 $SERVICE
      screen -dmS $SERVICE $BINDIR$SERVICE
      echo "Restarted $SERVICE at $(date +'%Y-%m-%d %T %Z'), because it was stunned..." > $OUTDIR$SERVICE.status
    else
      screen -S $SERVICE -p 0 -X hardcopy $OUTDIR$SERVICE.status
    fi
  fi
done
