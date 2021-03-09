#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00

LOG_FILE=test_output.log

if [ "${1}" == "gnu" ]; then
    module purge && module load gnu7 mvapich2 autotools
elif [ "${1}" == "intel" ]; then
    module purge && module load intel mvapich2 autotools
else
    exit 1 # Invalid module list requested
fi

source ${HOME}/geopm/integration/config/run_env.sh

# Run integration tests
export GEOPM_PLUGIN_PATH=${GEOPM_SOURCE}/.libs
export LD_LIBRARY_PATH=${GEOPM_SOURCE}/.libs:${LD_LIBRARY_PATH}
export PATH=${GEOPM_SOURCE}/.libs:${PATH}

pushd ${GEOPM_SOURCE}/integration/test

if [ "${2}" == "once" ]; then
    GEOPM_RUN_LONG_TESTS=true python3 . -v > >(tee -a integration_${LOG_FILE}) 2>&1
elif [ "${2}" == "loop" ]; then
    ./geopm_test_loop.sh
else
    exit 1 # Invalid test configuration requested
fi

touch .tests_complete
popd

