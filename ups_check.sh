#!/bin/bash

# auther: kevin
# overview: nut is awesome but way overkill for my needs. so a little shell script that runs via cron every minute to check ups state and shutdown
# last modified: 07.10.2018
# dependencies: obviously a ups and a working nut-server with basic config & apt-get install beep (if you want a audio sound
# todo: maybe add notification in later and more beeping and stuff

# config variables to set minimim battery charge
charge="40"
shutdown=$(shutdown -h now)

#set variables
upsstatus=$(upsc myups | grep ups.status > /etc/nut/status)
batstatus=$(cat /etc/nut/status | awk '{print $2}')
upscharge=$(upsc myups | grep battery.charge: > /etc/nut/upscharge)
batcharge=$(cat /etc/nut/upscharge | awk '{print $2}')
date=$(date)

# run some scripts to log to file (because of ssl error in stdout)
$upsstatus
$upscharge

# run logic to check battery and charge
if [ "$batstatus" == "OB" ] && [ $batcharge -lt $charge ];
then 
  echo "$date: UPS On Battery. Battery Charge is $batcharge shutting down now"	> /tmp/ups.log   
  beep
  beep
  beep
  $shutdown
  exit 1
else
    echo "$date: UPS On Mains Status: $batstatus and/or Battery Charge Still Good Battery: $batcharge percent" > /tmp/ups.log
    exit 0
fi
