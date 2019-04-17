#!/bin/bash

MAILING_LIST=${MAILING_LIST}
GEOPM_PATH=${HOME}/geopm

echo "MAILING_LIST is ${MAILING_LIST}"

find_latest_change () {
  local remote=$1
  local review=$2

  git ls-remote $remote | grep -E "refs/changes/[[:digit:]]+/${review}/" | sort -t / -k 5 -g | tail -n1 | awk '{print $2}'
}

cherrypick_wrapper(){
    # https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
    export GIT_HTTP_LOW_SPEED_TIME=600
    local remote=https://review.gerrithub.io/geopm/geopm

    # Use the following template for cherrypicking
    # Example : Killing a legacy.
    # Example : git fetch ${remote} $(find_latest_change ${remote} 409755) && git cherry-pick FETCH_HEAD
    git fetch ${remote} $(find_latest_change ${remote} ${1}) && git cherry-pick FETCH_HEAD

    return
}

cherrypick(){
    # USAGE: cherrypick_wrapper <GERRITHUB_PATCH_ID>
    cherrypick_wrapper 450062 # WIP : RAPL lock bit ignore.
    cherrypick_wrapper 451397 # WIP : Stop integration tests from littering files.
}

##############################
# Nightly test run
TIMESTAMP=$(date +\%F_\%H\%M)
TEST_DIR=${HOME}/public_html/cron_runs/${TIMESTAMP}
LOG_FILE=test_output.log

mkdir -p ${TEST_DIR}

echo "Starting integration test run..."

module purge && module load intel mvapich2 autotools

cd ${GEOPM_PATH}
git fetch --all
git reset --hard origin/dev
git clean -fdx
cherrypick

# Intel Toolchain (debug build for unit tests)
${HOME}/bin/go -ictg > >(tee -a ${TEST_DIR}/build_${LOG_FILE}) 2>&1
RC=$?
if [ ${RC} -ne 0 ]; then
    ERR_MSG="Running 'make' or 'make check' with the Intel toolchain failed.  Please see the output for more information:\n${TEST_OUTPUT_URL}/cron_runs/${TIMESTAMP}"

    echo -e ${ERR_MSG} | mail -r "do-not-reply" -s "Integration test failure : ${TIMESTAMP}" ${MAILING_LIST}

    echo "Email sent."
    exit 1
fi

# Intel Toolchain (release build for integration tests)
${HOME}/bin/go -ic > >(tee -a ${TEST_DIR}/build_${LOG_FILE}) 2>&1
make install

# Runs the integration tests 10 times
sbatch integration_batch.sh intel loop
# FIXME Make this launch resiliant to the script timing out
echo "Integration tests launched via sbatch.  Sleeping..."
while [ ! -f ${GEOPM_PATH}/test_integration/.tests_complete ]; do
    sleep 5
done
echo "Integration tests complete."

# Move the files into the TEST_DIR
echo "Moving files to ${TEST_DIR}..."
pushd test_integration
for f in $(ls -I "*h5" *log *report *trace-* *config .??*);
do
    mv ${f} ${TEST_DIR}
done
popd

# Send mail if there was a test failure.
if [ -f ${TEST_DIR}/.tests_failed ]; then
    ERR_MSG="The integration tests have failed.  Please see the output for more information:\nhttp://mcfly.ra.intel.com/~test/cron_runs/${TIMESTAMP}"

    echo -e ${ERR_MSG} | mail -r "do-not-reply" -s "Integration test failure : ${TIMESTAMP}" ${MAILING_LIST}

    echo "Email sent."
    # exit 1 # Since the integration tests are failing because of the cherrypick(), do not exit.
fi

# End test run
#############################

####################################
# Nightly coverage report generation
TIMESTAMP=$(date +\%F_\%H\%M)
TEST_DIR=${HOME}/public_html/coverage_runs/${TIMESTAMP}

mkdir -p ${TEST_DIR}

# GNU Toolchain - Runs unit tests, then integration tests, then generates coverage report
module purge && module load gnu7 mvapich2 autotools
export LD_LIBRARY_PATH=${GEOPM_PATH}/openmp/lib:${LD_LIBRARY_PATH}

cd ${GEOPM_PATH}
git fetch --all
git reset --hard origin/dev
git clean -fdx
cherrypick

go -dc > >(tee -a build_${LOG_FILE}) 2>&1

# Initial / baseline lcov
lcov --capture --initial --directory src --directory test --output-file base_coverage.info --no-external > >(tee -a coverage_${LOG_FILE}) 2>&1

# Run integration tests
sbatch integration_batch.sh gnu once
echo "Integration tests launched via sbatch.  Sleeping..."
while [ ! -f ${GEOPM_PATH}/test_integration/.tests_complete ]; do
    sleep 5
done
echo "Integration tests complete."

# Run unit tests
make check > >(tee -a check_${LOG_FILE}) 2>&1
# make coverage > >(tee -a check_${LOG_FILE}) 2>&1 # Target does lcov and genhtml calls

lcov --no-external --capture --directory src --directory test --output-file coverage.info > >(tee -a coverage_${LOG_FILE}) 2>&1

lcov --rc lcov_branch_coverage=1 -a base_coverage.info -a coverage.info -o combined_coverage.info > >(tee -a coverage_${LOG_FILE}) 2>&1

lcov --rc lcov_branch_coverage=1 --remove combined_coverage.info "$(pwd)/test*" "$(pwd)/contrib*" "$(pwd)/src/geopm_pmpi_fortran.c" "$(pwd)/gmock*" "/opt*" "/usr*" "5.3.0*" -o filtered_coverage.info > >(tee -a coverage_${LOG_FILE}) 2>&1

genhtml filtered_coverage.info --output-directory coverage --legend -t $(git describe) -f > >(tee -a coverage_${LOG_FILE}) 2>&1

# Copy coverage html to date stamped public_html dir
cp -rp coverage ${TEST_DIR}

# Copy unit and integration test outputs to dir
cp -rp --parents test/gtest_links ${TEST_DIR}
cp -rp --parents test/fortran/fortran_links ${TEST_DIR}

FILES=\
"test_integration/*log "\
"test_integration/*report "\
"test_integration/*trace-* " \
"test_integration/*config " \
"*info " \
"*log " \
"*out " \

for f in $(ls -I "*h5" ${FILES});
do
    cp -p --parents ${f} ${TEST_DIR}
done

# End nightly coverage report generation
########################################
