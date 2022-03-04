#!/bin/bash

set -e

if [ -f ${HOME}/.geopmrc ]; then
    source ${HOME}/.geopmrc
fi

LOG_DIR=${HOME}/public_html/build_logs/$(date +%F_%H)
mkdir -p ${LOG_DIR}

rm -fr ${HOME}/.local
rm -fr ${HOME}/.cache

# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py > ${LOG_DIR}/pip.log 2>&1
# python3 get-pip.py --user > ${LOG_DIR}/pip.log 2>&1
python3 -m pip install --user --ignore-installed --upgrade pip setuptools wheel pep517 >> ${LOG_DIR}/pip.log 2>&1 && \
python3 -m pip install --user --upgrade -r ${GEOPM_SOURCE}/service/requirements.txt >> ${LOG_DIR}/pip.log 2>&1 && \
python3 -m pip install --user --ignore-installed --upgrade -r ${GEOPM_SOURCE}/scripts/requirements.txt >> ${LOG_DIR}/pip.log 2>&1

RC=$?
if [ ${RC} -ne 0 ]; then
    TEST_LOG="${TEST_OUTPUT_URL}/cron_runs/${TIMESTAMP}/pip.log"
    ERR_MSG="pip has failed to install the python requirements.  Please see the log for more information:\n${TEST_LOG}\n"
    notify.sh "Integration test failure : ${TIMESTAMP}" "${ERR_MSG}"
    exit 1
fi
