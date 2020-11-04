#!/bin/bash

set -ex

# HOST=theta
# HOST=supermucng

TARGET=/usr/WS2/intelpwr/intelCRADA/output/${2}
# TARGET=${2}

# rsync -avhe ssh --progress ${1}:${TARGET} .
rsync -avhe ssh --progress --exclude '*h5*' --exclude '*trace*' ${1}:${TARGET} .

chmod o+rx $(basename ${2})
chmod o+r $(basename ${2})/*

