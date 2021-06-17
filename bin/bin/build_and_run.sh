#!/bin/bash -l

set -x

MAILING_LIST=${MAILING_LIST}

reset_pr(){
    2>/dev/null git checkout -b pr-test
    git reset --hard origin/dev
}

get_pr(){
    git fetch -f origin pull/${1}/head:pr-${1}
    git checkout pr-${1}
    git rebase pr-test
    git checkout pr-test
    git reset --hard pr-${1}
}

get_pull_requests(){
    # USAGE: get_pr <GITHUB_PR_NUMBER>
    get_pr 1699 # Use python3 everywhere; fixes make check
    return
}

##############################
# Nightly test run
export TIMESTAMP=$(date +\%F_\%H\%M)
TEST_DIR=${HOME}/public_html/cron_runs/${TIMESTAMP}
LOG_FILE=test_output.log

mkdir -p ${TEST_DIR}

echo "Starting integration test run..."

# Default toolchain (intel)
module purge && module load ohpc ccache
source ${HOME}/geopm/integration/config/build_env.sh

cd ${GEOPM_SOURCE}
git fetch --all
reset_pr
git clean -fdx --quiet
get_pull_requests

# Download required python dependencies
rm -fr ${HOME}/.local
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py > ${TEST_DIR}/pip.log 2>&1
# python3 get-pip.py --user > ${TEST_DIR}/pip.log 2>&1
pip install --user --ignore-installed --upgrade pip > ${TEST_DIR}/pip.log 2>&1
pip install --user --ignore-installed --upgrade -r scripts/requirements.txt > ${TEST_DIR}/pip.log 2>&1

# Intel Toolchain (debug build for unit tests)
go -ctg > ${TEST_DIR}/intel_debug_build_${LOG_FILE} 2>&1
RC=$?
if [ ${RC} -ne 0 ]; then
    TEST_LOG="${TEST_OUTPUT_URL}/cron_runs/${TIMESTAMP}/intel_debug_build_${LOG_FILE}"
    ERR_MSG="Running 'make' or 'make check' with the Intel toolchain failed.  Please see the output for more information:\n${TEST_OUTPUT_URL}/build_logs/build.${TIMESTAMP}.log\n${TEST_LOG}\n"

    echo -e ${ERR_MSG} | mail -r "do-not-reply" -s "Integration test failure : ${TIMESTAMP}" ${MAILING_LIST}

    notify.sh "Integration test failure : ${TIMESTAMP}" "${ERR_MSG}"

    echo "Email sent."
fi

# Intel Toolchain (release build for integration tests)
git clean -fdx --quiet
go -c > ${TEST_DIR}/intel_release_build_${LOG_FILE} 2>&1
./integration/test/test_tutorial_base.sh > ${TEST_DIR}/test_tutorial_base_${LOG_FILE} 2>&1
make install

# Runs the integration tests 10 times
sbatch integration_batch.sh intel loop
# FIXME Make this launch resiliant to the script timing out
echo "Integration tests launched via sbatch.  Sleeping..."
while [ ! -f ${GEOPM_SOURCE}/integration/test/.tests_complete ]; do
    sleep 5
done
echo "Integration tests complete."

# Move the files into the TEST_DIR
echo "Moving files to ${TEST_DIR}..."
pushd integration/test
for f in $(ls -I "*h5" *log *report *trace-* *config .??*);
do
    mv ${f} ${TEST_DIR}
done
popd

# Send mail if there was a test failure.
OUTPUT_LOG=cron_runs/${TIMESTAMP}/test_loop_output.log
TEST_OUTPUT_LOG=${TEST_OUTPUT_URL}/${OUTPUT_LOG}
if [ -f ${TEST_DIR}/.tests_failed ]; then
    ERR_MSG="The integration tests have failed.  Please see the output for more information:\n${TEST_OUTPUT_LOG}\n\nAdditional information here:\n${TEST_OUTPUT_URL}/cron_runs/${TIMESTAMP}"

    echo -e ${ERR_MSG} | mail -r "do-not-reply" -s "Integration test failure : ${TIMESTAMP}" ${MAILING_LIST}

    notify.sh "Integration test failure : ${TIMESTAMP}" "${ERR_MSG}"

    echo "Email sent."
    # exit 1 # Since the integration tests are failing because of the cherrypick(), do not exit.
else
    # Get skipped tests
    LOCAL_LOG=~/public_html/${OUTPUT_LOG}
    INT_9_LINE=$(grep -n skipped= ${LOCAL_LOG} | tail -n 2 | head -n 1 | cut -d: -f1)
    INT_9_LINE=$(( ${INT_9_LINE} + 1 ))
    SKIPPED_TESTS=$(tail -n +${INT_9_LINE} ${LOCAL_LOG} | grep skipped)
    # End get skipped

    ERR_MSG="The integration tests have PASSED! :).  Please see the output for more information:\n${TEST_OUTPUT_LOG}\n\nAdditional information here:\n${TEST_OUTPUT_URL}/cron_runs/${TIMESTAMP}\n\nSkipped tests:\n\n${SKIPPED_TESTS}\n"
    echo -e "${ERR_MSG}" | mail -r "do-not-reply" -s "Integration test PASS : ${TIMESTAMP}" ${MAILING_LIST}

    # Remove ' and " from SKIPPED_TESTS
    SKIPPED_TESTS=${SKIPPED_TESTS//\'/}
    SKIPPED_TESTS=${SKIPPED_TESTS//\"/}
    # Reformat ERR_MSG with Slack markup
    ERR_MSG="The integration tests have PASSED! :).  Please see the output for more information:\n${TEST_OUTPUT_LOG}\n\nAdditional information here:\n${TEST_OUTPUT_URL}/cron_runs/${TIMESTAMP}\n\nSkipped tests:\n\n\`\`\`${SKIPPED_TESTS}\`\`\`\n"
    notify.sh "Integration test PASS : ${TIMESTAMP}" "${ERR_MSG}"

    echo "PASS email sent."
fi

# End test run
#############################

####################################
# Nightly coverage report generation
export TIMESTAMP=$(date +\%F_\%H\%M)
TEST_DIR=${HOME}/public_html/coverage_runs/${TIMESTAMP}

mkdir -p ${TEST_DIR}

# GNU Toolchain - Runs unit tests, then integration tests, then generates coverage report
module purge && module load gnu9 mpich autotools cmake ccache
source ${HOME}/geopm/integration/config/gnu_env.sh
GEOPM_SKIP_COMPILER_CHECK=yes source ${HOME}/geopm/integration/config/build_env.sh
# export LD_LIBRARY_PATH=${GEOPM_SOURCE}/openmp/lib:${LD_LIBRARY_PATH}

cd ${GEOPM_SOURCE}
git fetch --all
reset_pr
git clean -fdx --quiet
get_pull_requests
# cherrypick

go -vc > ${TEST_DIR}/gnu_release_build_${LOG_FILE} 2>&1

# Initial / baseline lcov
lcov --capture --initial --directory src --directory test --output-file base_coverage.info --no-external > >(tee -a coverage_${LOG_FILE}) 2>&1

# Run integration tests
sbatch integration_batch.sh gnu once
echo "Integration tests launched via sbatch.  Sleeping..."
while [ ! -f ${GEOPM_SOURCE}/integration/test/.tests_complete ]; do
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
"integration/test/*log "\
"integration/test/*report "\
"integration/test/*trace-* "\
"integration/test/*config "\
"*info "\
"*log "\
"*out "\

set -x
for f in $(ls -I "*h5" ${FILES});
do
    cp -p --parents ${f} ${TEST_DIR}
done
set +x

RDY_MSG="The coverage report is ready:\n${TEST_OUTPUT_URL}/coverage_runs/${TIMESTAMP}/coverage\n\nAdditional data available in parent directory."
echo -e ${RDY_MSG}  | mail -r "do-not-reply" -s "Coverage report ready : ${TIMESTAMP}" ${MAILING_LIST}
notify.sh "Code coverage : ${TIMESTAMP}" "${RDY_MSG}"

# End nightly coverage report generation
########################################
