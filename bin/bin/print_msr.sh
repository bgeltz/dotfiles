#!/bin/bash

DATE=$(date +%F_%H%M.%S)
RDMSR=${HOME}/build/msr-tools/bin/rdmsr
echo "Reading MSR ${1}..."
${RDMSR} -a $1 | tee rdmsr_${1}_$(hostname)_${DATE}.txt

