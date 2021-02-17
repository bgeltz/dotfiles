#!/bin/bash

TITLE="$1"
MSG="$2"

if [ -z ${SLACK_HOOK+x} ]; then
    echo "Error: SLACK_HOOK not set in environment!"
    exit 0
fi

curl -X POST -H 'Content-type: application/json' --data "{'text':'*${1}*: ${2}'}" ${SLACK_HOOK}

