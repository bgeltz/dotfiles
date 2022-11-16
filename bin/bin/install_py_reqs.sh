#!/bin/bash

if [ -f ${HOME}/.geopmrc ]; then
    source ${HOME}/.geopmrc
fi

if [ -z "${TIMESTAMP}" ]; then
    TIMESTAMP=$(date +\%F_\%H\%M)
fi

if [ -z "${LOG_DIR}" ]; then
    LOG_DIR=.
fi

LOG_FILE="${LOG_DIR}/pip.log"

rm -fr ${HOME}/.local
rm -fr ${HOME}/.cache

# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py > ${LOG_FILE} 2>&1
# python3 get-pip.py --user > ${LOG_FILE} 2>&1
python3 -m pip install --user --ignore-installed --upgrade pip setuptools wheel pep517 >> ${LOG_FILE} 2>&1 && \
python3 -m pip install --user --upgrade -r ${GEOPM_SOURCE}/service/requirements.txt >> ${LOG_FILE} 2>&1 && \
python3 -m pip install --user --ignore-installed --upgrade -r ${GEOPM_SOURCE}/scripts/requirements.txt >> ${LOG_FILE} 2>&1
python3 -m pip install --user --ignore-installed --upgrade -r ${GEOPM_SOURCE}/integration/requirements.txt >> ${LOG_FILE} 2>&1
