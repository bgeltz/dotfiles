#!/bin/bash

set -ex

source ~/.geopmrc

TEST_DIR=${GEOPM_SOURCE}/service
REPORT_DIR=${HOME}/public_html/pytest_coverage
REMOTE=origin
BRANCH=dev

cd ${TEST_DIR}
git clean -ffdx

git checkout ${BRANCH}
git reset --hard ${REMOTE}/${BRANCH}

# Checkout desired branch/commit at sprint start
SPRINT_START_DATE="2022-01-19"
START_DIR=${REPORT_DIR}/${SPRINT_START_DATE}_0000
mkdir -p ${START_DIR}

# https://stackoverflow.com/questions/6990484/how-to-checkout-in-git-by-date
git checkout "${REMOTE}/${BRANCH}@{${SPRINT_START_DATE} 00:00:00}"
git log -1 > ${START_DIR}/tophash
LD_LIBRARY_PATH="${GEOPM_INSTALL}/lib" PYTHONPATH="." \
    pytest --cov=geopmdpy geopmdpy_test/Test*.py \
           --cov-report=html:${START_DIR}

# Checkout at sprint end
git checkout - # Go back to where we started first

# git fetch origin
# git checkout origin/dev
# git checkout issue-1803
git checkout issue-2077
# git checkout origin/pr/2084 # FIXME Hack till everything is merged

END_DIR=${REPORT_DIR}/$(date +%F_%H%M)
mkdir -p ${END_DIR}
git log -1 > ${END_DIR}/tophash
LD_LIBRARY_PATH="${GEOPM_INSTALL}/lib" PYTHONPATH="." \
    pytest --cov=geopmdpy geopmdpy_test/Test*.py \
           --cov-report=html:${END_DIR}

git checkout -

