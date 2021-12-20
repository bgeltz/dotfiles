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
    git fetch ${REMOTE}
    git checkout ${BRANCH}
    git reset --hard ${REMOTE}/${BRANCH}
fi
git clean -ffdx

# Build and install service and base build locally
pushd service
./autogen.sh
CC=gcc CXX=g++ ./configure --prefix=${GEOPM_INSTALL}
make -j9
make -j9 checkprogs
make install
make rpm
popd
./autogen.sh
source integration/config/build_env.sh
./configure --prefix=${GEOPM_INSTALL}
make -j9
make -j9 checkprogs
make install

# build tutorial on head node
./integration/test/test_tutorial_base.sh

# Run the GEOPM HPC Runtime integration tests
test_dir=$(mktemp -d -p${GEOPM_WORKDIR} test-service-$(date +%Y-%m-%d)-XXXXX)
cd ${test_dir}
sbatch --wait ${GEOPM_TEST_SBATCH}

echo '######################################################################'
echo '# SUCCESS: test-service.sh '$(date)
echo '######################################################################'
