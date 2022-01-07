#!/bin/bash -l

echo '######################################################################'
echo '# BEGIN: test-service.sh '$(date)
echo '######################################################################'
set -e
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
    git fetch ${REMOTE}
    git checkout ${BRANCH}
    git reset --hard ${REMOTE}/${BRANCH}
fi

# Build and install service and base build locally
./integration/config/build.sh
cd service
make rpm
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

