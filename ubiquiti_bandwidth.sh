#!/bin/bash

# script to upload Ubiquiti WLAN0 interface TX and RX to domoticz.
# Dependencies: Create 2 dummy switches of type "Counter",  SNMP enabled on the Ubiquiti, snmpwalk installed on the host running your domoticz where this script runs

#setup
host='localhost:8080'
idxbwdown=55
idxbwup=54
router=10.0.0.1

# Commands to run to test snmpwalk from commandline
#/usr/bin/snmpwalk -v1 -c public 10.0.0.1 iso.3.6.1.2.1.2.2.1.10.5
#/usr/bin/snmpwalk -v1 -c public 10.0.0.1 iso.3.6.1.2.1.2.2.1.16.5

getdown=$(/usr/bin/snmpwalk -v1 -c public $router iso.3.6.1.2.1.2.2.1.10.5 | awk '{ print $4 }')
getup=$(/usr/bin/snmpwalk -v1 -c public $router iso.3.6.1.2.1.2.2.1.16.5 | awk '{ print $4 }')
calcgbdown=$(awk "BEGIN {print $getdown/1024/1024}")
calcgbup=$(awk "BEGIN {print $getup/1024/1024}")
calcup_last=$(cat bandwidth_lastup.txt)
calcdown_last=$(cat bandwidth_lastdown.txt)
calcgbup_diff=$(awk "BEGIN {print $calcgbup - $calcup_last}")
calcgbdown_diff=$(awk "BEGIN {print $calcgbdown - $calcdown_last}")

# output if you run manually
echo $calcgbdown > bandwidth_lastdown.txt
echo $calcgbup > bandwidth_lastup.txt
echo $calcgbup_diff MB Uploads
echo $calcgbdown_diff MB Downloads


# Updating download, upload and ping ..
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxbwdown&svalue=$calcgbdown_diff" >/dev/null 2>&1
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxbwup&svalue=$calcgbup_diff" >/dev/null 2>&1

# Domoticz logging
wget -q --delete-after "http://$host/json.htm?type=command&param=addlogmessage&message=bandwidthmonitor.net-logging" >/dev/null 2>&1
