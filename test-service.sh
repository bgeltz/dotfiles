#!/bin/bash

echo '######################################################################'
echo '# BEGIN: test-service.sh '$(date)
echo '######################################################################'
set -e
set -x

export GEOPM_WORKDIR=/home/test-service/output
export GEOPM_SOURCE=/home/test-service/geopm-cmcantal
export GEOPM_TEST_SBATCH=/home/test-service/test-service/test-service.sbatch

source /etc/profile.d/lmod.sh
module purge
module load ohpc autotools intel impi mkl

# Set up git repository
cd ${GEOPM_SOURCE}
git fetch public
git checkout dev
git reset --hard public/dev
git clean -dfx

# Build and install service and base build locally
pushd service
./autogen.sh
CC=gcc CXX=g++ ./configure --prefix=$HOME/build/geopm-cmcantal
make -j20
make -j20 checkprogs
make install
make rpm
popd
./autogen.sh
source integration/config/build_env.sh
./configure --prefix=${HOME}/build/geopm-cmcantal
make -j20
make -j20 checkprogs
make install

# Run the GEOPM HPC Runtime integration tests
test_dir=$(mktemp -d -p${GEOPM_WORKDIR} test-service-$(date +%Y-%m-%d)-XXXXX)
cd ${test_dir}
sbatch --wait ${GEOPM_TEST_SBATCH}

echo '######################################################################'
echo '# SUCCESS: test-service.sh '$(date)
echo '######################################################################'
