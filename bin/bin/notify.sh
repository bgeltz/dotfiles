#!/bin/bash

TITLE="$1"
MSG="$2"

curl -u ${PUSHBULLET_API_KEY}: https://api.pushbullet.com/v2/pushes -d type=note -d title="${TITLE}" -d body="${MSG}" > /dev/null
