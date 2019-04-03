#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH -N 4
#SBATCH --export=ALL
#SBATCH -t 08:00:00

LOG_FILE=test_output.log
GEOPM_PATH=${HOME}/geopm
PATH=${GEOPM_PATH}/.libs:${PATH}

if [ "${1}" == "gnu" ]; then
    module purge && module load gnu7 mvapich2 autotools
elif [ "${1}" == "intel" ]; then
    module purge && module load intel mvapich2 autotools
else
    exit 1 # Invalid module list requested
fi

# Run integration tests

# Uncomment the next line if using --enable-ompt!
#export LD_PRELOAD=${GEOPM_PATH}/openmp/lib/libomp.so
export GEOPM_PLUGIN_PATH=${GEOPM_PATH}/.libs
#export LD_LIBRARY_PATH=/opt/ohpc/pub/compiler/gcc/5.3.0/lib64:${GEOPM_PATH}/.libs:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${GEOPM_PATH}/.libs:${LD_LIBRARY_PATH}

pushd ${GEOPM_PATH}/test_integration

if [ "${2}" == "once" ]; then
    GEOPM_RUN_LONG_TESTS=true ./geopm_test_integration.py -v > >(tee -a integration_${LOG_FILE}) 2>&1
elif [ "${2}" == "loop" ]; then
    ./geopm_test_loop.sh
else
    exit 1 # Invalid test configuration requested
fi

touch .tests_complete
popd

