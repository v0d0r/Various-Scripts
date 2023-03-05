#!/bin/bash
: <<'EOF'
This script requires the following components.

1. A API token from EskomSePush developers site.
Regiser and get create a token here: https://eskomsepush.gumroad.com/l/api
Free 50 requests per day
More info here https://documenter.getpostman.com/view/1296288/UzQuNk3E#intro

2. Get the correct area
See above documentation and/or use the mobile app to figure that out

3. Setup a cron to run every minute past the hour to pull the latest schedule and save to json (they seem to update this every 30 minutes if there are changes)

root@odroidc2:/home/vodor# cat /etc/cron.d/eskom-schedule
1 * * * *	root	/home/vodor/scripts/eskom-schedule.sh	>> /dev/null 2>&1

#content of script to pull schedule and save where you will run the script from.
#!/bin/bash

curl --location --request GET 'https://developer.sepush.co.za/business/2.0/area?id=capetown-11-bergvliet' --header 'token: 123456-7891234-123456' | jq > /home/vodor/scripts/bergvliet.txt

4. Make sure you have jq installed

5. The second script (The one you are viewing now) will use the schedule from the above file and apply the logic to shutdown.
The default is to shutdown 3 hours into a 4 hour load shedding schedule (as my batteries only last so long for now)

EOF

# Script variables start here:

eventstart=$(cat /home/vodor/scripts/bergvliet.txt | jq -r '.events[] | .start' | head -1)
eventend=$(cat /home/vodor/scripts/bergvliet.txt | jq -r  '.events[] | .end' | head -1)
currenttime=$(date '+%FT%T%:z')
##  change this to 65 minutes will shutdown 1 hour into a 2 hour load shedding
##  change this to 175 minutes will shutdown 3 hours into a 4 hour load shedding
##  see logic of these values lower down
currentimemin=$(date --date '-175 min' '+%FT%T%:z')

START=$(date +%s -d $eventstart)
END=$(date +%s -d $eventend)
NOW=$(date +%s -d $currenttime)
NOWMin=$(date +%s -d $currentimemin)
LIMIT=1
HOURS=$(( ($END - $START) / 60 / 60 ))


if [ "$NOWMin" -ge "$START" ] && [ $END -gt $NOW ]; then
  echo "nowmin 2half hours is $currentimemin start time is $eventstart"
  echo "end time is $eventend and now is $currenttime"
  # shutdown some servers make sure your ssh keys are copied over and working
  ssh root@10.0.0.1 /usr/sbin/shutdown -h now
  ssh root@10.0.0.2 /usr/sbin/shutdown -h now
  # shutdown qnap nas make sure your ssh keys are copied over and working
  ssh vodor@10.0.0.3 "echo secret123 | sudo -S /sbin/poweroff"
  # write entry to log for debugging
echo "$currenttime shutdown required" >> /var/log/fsck-eskom.log
sleep 10
 # shutdown local server where this script runs from
  sudo shutdown -h now ; else
  # write entry to log for debugging
  echo "$currenttime no shutdown required" >> /var/log/fsck-eskom.log
fi


##Logic for 1 hour into 2 hour load shedding (example assumes start is 12:00 and end is 14:00)
# 13:00 - 55 min = 12:05
#start = 12:00
#end = 14:00
#if 12:05 is grater than 12:00
#and 14:00 is greater than 13:00
#then

##Logic for 3 hours into 4 hours load shedding (example assumes start is 12:00 and end is 16:00)
#15:00 - 175 = 12:05
#start = 12:00
#end = 16:00
#if 12:05 is grater than 12:00
#and 16:00 is greater than 15:00
#then
