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

RC=$?
if [ ${RC} -ne 0 ]; then
    SHORT_PATH="$(realpath --relative-base ${HOME}/public_html ${LOG_FILE})"

    LOG_URL="${TEST_OUTPUT_URL}/${SHORT_PATH}"
    ERR_MSG="pip has failed to install the python requirements.  Please see the log for more information:\n${LOG_URL}\n"
    notify.sh "Integration test failure : ${TIMESTAMP}" "${ERR_MSG}"
    exit 1
fi
