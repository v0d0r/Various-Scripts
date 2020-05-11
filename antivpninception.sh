#!/bin/bash

# vpn anti inception script. 
# when u use a vpn provider like expressvpn that becomes your default route and you dont want secondary vpn's to connect via existing expressvpn

#set variables
vpnip=$(dig +short myhomevpndomain.com)
routecheck=$(route -n | grep $vpnip | wc -l)
oldroute=$(cat /home/pi/scripts.lastvpnip.log)

if [ "$routecheck" -gt "0" ];
then
  echo "nothing to do. vpn already routes via router gateway"
  exit 0
else
  echo " "
  echo "vpn inception happening. fixing route"
  echo " "
  echo "performing cleanup of old routes"
  ip route del $oldroute/32 via 192.168.8.1
  echo "adding new vpn route"
  ip route add $vpnip/32 via 192.168.8.1
  echo "done new route added as follows"
  route -n | grep $vpnip
  echo $vipip > /home/pi/scripts/lastvpnip.log
fi
