#!/bin/bash

UPS_NAME="myups"

GATHER_COMMAND="upsc ${UPS_NAME}"

(
  M_CHARGE=$(${GATHER_COMMAND} | grep battery.charge | cut -d' ' -f2)
  M_INVOLT=$(${GATHER_COMMAND} | grep input.voltage: | cut -d' ' -f2)
  M_OUTVOLT=$(${GATHER_COMMAND} | grep output.voltage | cut -d' ' -f2)
  B_VOLTAGE=$(${GATHER_COMMAND} | grep battery.voltage: | cut -d' ' -f2)
#  M_TEMPERATURE=$(${GATHER_COMMAND} | grep ups.temperature | cut -d' ' -f2)

  # cpu,host=server01,region=uswest value=1 1434055562000000000
METRICS="charge_perc=${M_CHARGE},input_v=${M_INVOLT},output_v=${M_OUTVOLT},battery_v=${B_VOLTAGE}"

#  echo ups,host=$(hostname --fqdn),ups=${UPS_NAME} ${METRICS}
echo ups,ups=${UPS_NAME} ${METRICS} $(date +%s%N)
##$(date +%s%N)
) 2>/dev/null
