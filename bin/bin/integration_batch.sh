#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00
#SBATCH -o test.sbatch.%j.log
#SBATCH -e test-service.sbatch.%j.err

LOG_FILE=test_output.log

source ${HOME}/geopm/integration/config/run_env.sh

if [ "${1}" == "gnu" ]; then
    module purge && module load gnu9 mpich autotools ccache
    # Set LD_LIBARY_PATH and PATH since the GNU run is performed without 'make install'
    export LD_LIBRARY_PATH=${GEOPM_SOURCE}/service/.libs:${GEOPM_SOURCE}/.libs:${LD_LIBRARY_PATH}
    export PATH=${GEOPM_SOURCE}/service/.libs:${GEOPM_SOURCE}/.libs:${PATH}
elif [ "${1}" == "intel" ]; then
    module purge && module load ohpc
else
    exit 1 # Invalid module list requested
fi

if [ "${2}" == "once" ]; then
    python3 -m unittest discover \
            --top-level-directory ${GEOPM_SOURCE} \
            --start-directory ${GEOPM_SOURCE}/integration/test \
            --pattern 'test_*.py' \
            --verbose >& >(tee -a integration_${LOG_FILE})
elif [ "${2}" == "loop" ]; then
    ${GEOPM_SOURCE}/integration/test/geopm_test_loop.sh
else
    exit 1 # Invalid test configuration requested
fi
popd

touch .tests_complete

