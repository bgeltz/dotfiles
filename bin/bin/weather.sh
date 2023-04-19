#!/bin/bash

# https://github.com/chubin/wttr.in
while : ; do
    clear
    # curl wttr.in/hio
    date
    # curl wttr.in/97007?0FnQp
    curl wttr.in/Beaverton,OR?0Fnqp
    curl wttr.in/Palo+Alto,CA?0Fnqp
    curl wttr.in/Boston,MA?0Fnqp
    sleep 600
done
