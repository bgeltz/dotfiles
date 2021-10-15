#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00

LOG_FILE=test_output.log

source ${HOME}/geopm/integration/config/run_env.sh

if [ "${1}" == "gnu" ]; then
    module purge && module load gnu9 mpich autotools
    # Set LD_LIBARY_PATH and PATH since the GNU run is performed without 'make install'
    export LD_LIBRARY_PATH=${GEOPM_SOURCE}/service/.libs:${GEOPM_SOURCE}/.libs:${LD_LIBRARY_PATH}
    export PATH=${GEOPM_SOURCE}/service/.libs:${GEOPM_SOURCE}/.libs:${PATH}
elif [ "${1}" == "intel" ]; then
    module purge && module load ohpc
else
    exit 1 # Invalid module list requested
fi

# Run integration tests
LEGACY_DIR=${GEOPM_SOURCE}/integration/test
pushd ${LEGACY_DIR}

if [ "${2}" == "once" ]; then
    GEOPM_RUN_LONG_TESTS=true python3 . -v > >(tee -a integration_${LOG_FILE}) 2>&1
elif [ "${2}" == "loop" ]; then
    ./geopm_test_loop.sh
else
    exit 1 # Invalid test configuration requested
fi
popd

touch ${LEGACY_DIR}/.tests_complete

