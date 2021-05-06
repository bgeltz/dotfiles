#!/bin/bash

#awk -F\| '{print $16, $17, $18, $19, $20}' gadget_monitor_0.trace-mcfly10 | tail -n +7 | head | column -s ' ' -t
#cut -d\| -f16-20 gadget_monitor_0.trace-mcfly10 | head | column -s '|' -t

cut -d\| -f${2}-${3} ${1} | column -s '|' -t
