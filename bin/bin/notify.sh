#!/bin/bash

TITLE="$1"
MSG="$2"

if [ -z ${PUSHBULLET_API_KEY+x} ]; then
    echo "Error: PUSHBULLET_API_KEY not set in environment!"
    exit 1
fi

curl -u ${PUSHBULLET_API_KEY}: https://api.pushbullet.com/v2/pushes -d type=note -d title="${TITLE}" -d body="${MSG}" > /dev/null
