#!/bin/bash

# auther: kevin
# overview: check if domoticz bound to port and restart if not because of shitty power utlity loadshedding our power feeds
# last modified: 05.12.2018
# dependencies: n/a
# todo: n/a

# config variables to set minimim battery charge
expected="0.0.0.0:8080"
restartdomoticz=$(/etc/init.d/domoticz.sh restart)

#set variables
checkrunning=$(netstat -punta | grep 8080 | awk '{print $4}')
date=$(date)

# run logic to check battery and charge
if [ "$checkrunning" != $expected ];
then 
  echo "$date: starting up domoticz its not listening on port 8080"     > /tmp/checkdomoticz.log   
  $restartdomoticz
  exit 1
else
    echo "$date: domoticz seems to be listening on port 80 no action" > /tmp/checkdomoticz.log
    exit 0
fi

