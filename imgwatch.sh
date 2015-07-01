#!/bin/bash
IMG=/root/pendrive.img
CPSCRIPT=filecp.sh

PID=""

inotifywait -m $IMG | while read line
do
 if echo $line | grep -iq "MODIFY"; then
   if [ -n "$PID" ]; then
     kill -9 $PID && PID=""
   fi
   ./${CPSCRIPT} &
   PID=$!
fi
done