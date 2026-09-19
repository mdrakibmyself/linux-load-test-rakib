#!/bin/bash
# Replace "bgdsvc_yourname" below with your ACTUAL chosen name (typed literally —
# this file is not a shell session, so $SVC_NAME won't expand here).
SVC_NAME="bgdsvc_yourname"
LOGFILE="/var/log/${SVC_NAME}/monitor.log"

echo "---- $(date) ----" >> "$LOGFILE"
free -h >> "$LOGFILE"
df -h "/mnt/${SVC_NAME}_tmp" >> "$LOGFILE" 2>&1
ps -u "$SVC_NAME" >> "$LOGFILE" 2>&1