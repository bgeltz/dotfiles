#!/bin/bash

# Requires pytest, pytest-cov
# python3 -m pip install --user pytest pytest-cov

set -ex

source ~/.geopmrc

TEST_DIR=${GEOPM_SOURCE}/service
# REPORT_DIR=${HOME}/public_html/pytest_coverage
REPORT_DIR=${HOME}/public_html/testing
REMOTE=origin
# BRANCH=dev
BRANCH=$(git rev-parse --abbrev-ref HEAD)

cd ${TEST_DIR}
# git clean -ffdx

# You have to run configure to ensure *.py.in files are processed (e.g. schemas.py.in)
# ./autogen.sh
# ./configure.sh

# git checkout ${BRANCH}
# git reset --hard ${REMOTE}/${BRANCH}

# Checkout desired branch/commit at sprint start
# SPRINT_START_DATE="2022-02-02"
# START_DIR=${REPORT_DIR}/${SPRINT_START_DATE}_0000
START_DIR=${REPORT_DIR}/${BRANCH}_$(date +%F_%H%M)
mkdir -p ${START_DIR}

# # https://stackoverflow.com/questions/6990484/how-to-checkout-in-git-by-date
# git checkout "${REMOTE}/${BRANCH}@{${SPRINT_START_DATE} 00:00:00}"
# Checkout specific hash if things were in flight at the end of the last sprint
# git checkout fc957ee35ac096955e21e66c7e0cfb141da3b012

git log -1 > ${START_DIR}/tophash
LD_LIBRARY_PATH="${GEOPM_INSTALL}/lib" PYTHONPATH="." \
    pytest --cov=geopmdpy geopmdpy_test/Test*.py \
           --cov-report=html:${START_DIR}

exit 0

# Checkout at sprint end
git checkout - # Go back to where we started first

# git fetch origin
# git checkout origin/dev
# git checkout issue-1803
# git checkout issue-2077
# git checkout origin/pr/2084 # FIXME Hack till everything is merged

END_DIR=${REPORT_DIR}/$(date +%F_%H%M)
mkdir -p ${END_DIR}
git log -1 > ${END_DIR}/tophash
LD_LIBRARY_PATH="${GEOPM_INSTALL}/lib" PYTHONPATH="." \
    pytest --cov=geopmdpy geopmdpy_test/Test*.py \
           --cov-report=html:${END_DIR}

# git checkout -

