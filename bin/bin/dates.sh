#!/bin/bash

BIRTHDAYS=${HOME}/.gcal/birthdays
VIP_DATES=${HOME}/.gcal/brgdates

# Display birthdays and holidays
gcal -f ${BIRTHDAYS} --heading-text="Birthdays:" --starting-day=Monday --with-week-number --iso-week-number=yes -q US_OR -n- .+

# Display VIP dates
gcal -f ${VIP_DATES} --heading-text="2020:" -u 2020
gcal -f ${VIP_DATES} --heading-text="2021:" -u 2021

