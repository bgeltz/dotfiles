#!/bin/bash -l

reset_pr_test(){
    git switch -C pr-test
    git reset --hard origin/dev
}

get_pr(){
    set -e
    git fetch -f origin pull/${1}/head:pr-${1}
    git checkout pr-${1}
    git rebase pr-test
    git checkout pr-test
    git reset --hard pr-${1}
    set +e
}

echo '######################################################################'
echo '# BEGIN: test-service.sh '$(date)
echo '######################################################################'
set -x

module purge
module load ohpc ccache

source ${HOME}/geopm/integration/config/build_env.sh
export GEOPM_TEST_SBATCH=${HOME}/test-service/test-service.sbatch
# GEOPM_SKIP_CHECKOUT=True

# Set up git repository
REMOTE=origin
BRANCH=dev
cd ${GEOPM_SOURCE}
if [ -z "$GEOPM_SKIP_CHECKOUT" ]; then
    git clean -ffdx
    git fetch -f ${REMOTE}
    git checkout ${BRANCH}
    git reset --hard ${REMOTE}/${BRANCH}
    # Uncomment BOTH of the following lines when cherry-picking PRs
    # reset_pr_test
    # get_pr 2428
fi

# Install py reqs
# Logs go to ~/public_html/build_logs/pip*
install_py_reqs.sh

# Build and install service and base build locally
GEOPM_SERVICE_CONFIG_OPTIONS="--disable-io-uring" ./integration/config/build.sh
make -j9 checkprogs
cd service
rpmbuild_flags='--define "disable_io_uring 1"' make rpm
# rpmbuild_flags='--define "enable_level_zero 1"' make rpm
cd ..

# build tutorial on head node
./integration/test/test_tutorial_base.sh

# Run the GEOPM HPC Runtime integration tests
TEST_DIR=$(mktemp -d -p${GEOPM_WORKDIR} test-service-$(date +%Y-%m-%d)-XXXXX)
chmod 755 ${TEST_DIR}
ln -sfn ${TEST_DIR} $(dirname ${TEST_DIR})/latest

cd ${TEST_DIR}
sbatch --wait ${GEOPM_TEST_SBATCH}

ERR=$?
MSG="\n######################################################################\n"
if [ "${ERR}" -eq 0 ]; then
    MSG+="# SUCCESS: test-service.sh $(date) \n"
else
    MSG+="# FAILURE: test-service.sh $(date) \n"
fi
MSG+="######################################################################\n"
MSG+="Results available here: ${TEST_OUTPUT_URL}/cron_runs/${TEST_DIR##*/}"

echo ${MSG}
notify.sh "test-service" "${MSG}"

