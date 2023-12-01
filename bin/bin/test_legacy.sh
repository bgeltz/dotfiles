#!/bin/bash -l

reset_pr_test(){
    git switch -C pr-test
    git reset --hard origin/dev
}

get_pr(){
    git fetch -f origin pull/${1}/head:pr-${1}
    git checkout pr-${1}
    git rebase pr-test
    git checkout pr-test
    git reset --hard pr-${1}
}

path_to_link(){
    local SHORT_PATH="$(realpath --no-symlinks --relative-base ${HOME}/public_html ${1})"
    local LOG_URL="${TEST_OUTPUT_URL}/${SHORT_PATH}"
    echo "${LOG_URL}"
}

check_rc(){
    local RC=$?
    local ERR_MSG=${1}
    local LOG_URL=$(path_to_link ${2})

    if [ ${RC} -ne 0 ]; then
        # Remove ' and " from ERR_MSG
        ERR_MSG=${ERR_MSG//\'/}
        ERR_MSG=${ERR_MSG//\"/}
        notify.sh "Integration test failure : ${TIMESTAMP}" "${ERR_MSG}\n${LOG_URL}"
        exit ${RC}
    fi
}

echo '######################################################################'
echo "# BEGIN: $(basename ${0}) - $(date)"
echo '######################################################################'

# Load modules
module purge
module load ohpc ccache

# Setup output dirs
export TIMESTAMP=$(date +\%F_\%H\%M)
export LOG_DIR=${HOME}/public_html/cron_runs/${TIMESTAMP}
mkdir -p ${LOG_DIR}
check_rc "Output directory creation failed.  The disk is full." "/"
ln -sfn ${LOG_DIR} $(dirname ${LOG_DIR})/latest
check_rc "Symlink to output directory creation failed.  The disk is full." "/"

# Setup build environment
source ${HOME}/geopm/integration/config/build_env.sh

# Set up git repository
REMOTE=origin
BRANCH=dev
cd ${GEOPM_SOURCE}
if [ -z "${GEOPM_SKIP_CHECKOUT}" ]; then
    git clean -ffdx --quiet
    git fetch -f ${REMOTE}
    git checkout ${BRANCH}
    git reset --hard ${REMOTE}/${BRANCH}

    # Uncomment BOTH of the following lines when cherry-picking PRs
    # reset_pr_test
    # get_pr XXXX
fi

# Install py reqs
install_py_reqs.sh
check_rc "Installing python requirements with pip failed" "${LOG_DIR}/pip.log"

# DEBUG build w/Intel for maximum unit test coverage
GEOPM_GLOBAL_CONFIG_OPTIONS="--enable-debug" \
GEOPM_BASE_CONFIG_OPTIONS="--enable-beta" \
GEOPM_SERVICE_CONFIG_OPTIONS="--enable-levelzero --disable-io-uring" \
GEOPM_RUN_TESTS=yes \
./integration/config/build.sh \
> ${LOG_DIR}/build_intel_debug.out \
2> ${LOG_DIR}/build_intel_debug.err
check_rc "Intel/debug build or 'make check' failed" "${LOG_DIR}/build_intel_debug.err"

# RELEASE build w/Intel for integration tests
git clean -ffdx --quiet
GEOPM_BASE_CONFIG_OPTIONS="--enable-beta" \
GEOPM_SERVICE_CONFIG_OPTIONS="--enable-levelzero --disable-io-uring" \
./integration/config/build.sh \
> ${LOG_DIR}/build_intel_release.out \
2> ${LOG_DIR}/build_intel_release.err
check_rc "Intel/release build failed" "${LOG_DIR}/build_intel_release.err"

# Build integration test binaries
make -j9 checkprogs \
>> ${LOG_DIR}/build_intel_release.out \
2>> ${LOG_DIR}/build_intel_release.err
check_rc "Intel/release build checkprogs target failed" "${LOG_DIR}/build_intel_release.err"

# Build the tutorials
./integration/test/test_tutorial_base.sh > ${LOG_DIR}/build_tutorials.log 2>&1
check_rc "Tutorial build failed" "${LOG_DIR}/build_tutorials.log"

# Build the service RPM
cd service
make rpm > ${LOG_DIR}/build_rpm.log 2>&1
check_rc "rpm build failed" "${LOG_DIR}/build_rpm.log"
cd ..

build_app(){
    APP=${1}
    ARGS=${2}
    cd ${GEOPM_SOURCE}/integration/apps/${APP}
    ./build.sh ${ARGS} > ${LOG_DIR}/build_${APP}.log 2>&1
    check_rc "${APP} build failed" "${LOG_DIR}/build_${APP}.log"
    cd -
}

# Build apps for weekend tests
if [ $(date +%u) -gt 5 ]; then
    build_app amg
    build_app arithmetic_intensity
    build_app hpcg mcfly
    build_app hpl_netlib
    build_app minife
    build_app parres oneapi
    build_app pennant
fi

# Begin the job
cd ${LOG_DIR}
suite_failed=0
max_iterations=10
passed_tests=0
sbatch_job_id=$(sbatch --parsable \
                       --array "1-${max_iterations}" \
                       -o 'test_loop-%A_%a.out' \
                       ${HOME}/bin/test_legacy.sbatch)

# Make non-glob-matches result in empty output instead of returning the glob itself
# Do this so we can count glob matches as file elements in a bash array.
shopt -s nullglob

echo "Integration tests launched via sbatch.  Sleeping..."
set -x
while [ "$passed_tests" -lt "$max_iterations" ]; do
        passed_test_list=(.tests_complete.*)
        failed_test_list=(.tests_failed.*)
        passed_tests="${#passed_test_list[@]}"
        failed_tests="${#failed_test_list[@]}"
        if [ "$failed_tests" -ne 0 ]; then
                echo "Encountered a failure after ${passed_tests} passing iterations."
                echo "Canceling the remaining iterations"
                scancel ${sbatch_job_id}
                suite_failed=1
                break
        fi
        sleep 5
done

# Each array-job element was outputting to its own out file so they don't
# interleave if they execute at the same time. Combine into a single log
# if we want to keep the current usage (single hyperlink in Slack failure messages)
cat "test_loop-${sbatch_job_id}_"*.out > test_loop_output.log
echo "Integration tests complete."

#########################

MSG="\n######################################################################\n"
if [ "${suite_failed}" -eq 0 ]; then
    MSG+="# SUCCESS: $(basename ${0}) $(date) \n"
else
    MSG+="# FAILURE: $(basename ${0}) $(date) \n"
fi
MSG+="######################################################################\n"
MSG+="Results available here: $(path_to_link ${LOG_DIR}/test_loop_output.log)"

echo ${MSG}
notify.sh "test-legacy" "${MSG}"

