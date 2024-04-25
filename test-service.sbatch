#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00
#SBATCH -o test-service.sbatch.%j.log
#SBATCH -e test-service.sbatch.%j.err

source ${HOME}/geopm/integration/config/run_env.sh

#export GEOPM_RUN_LONG_TESTS=TRUE
unset GEOPM_RUN_LONG_TESTS

install_service.sh
rc=$?
if [ "${rc}" -ne 0 ]; then
    echo "ERROR: Installing the GEOPM Access Service failed"
    exit ${rc}
fi

python3 -m unittest discover \
        --top-level-directory ${GEOPM_SOURCE} \
        --start-directory ${GEOPM_SOURCE}/integration/test \
        --pattern 'test_*.py' \
        --verbose &>> test-service.log
ERR=$?

if [ "${ERR}" -eq 0 ]; then
    python3 -m unittest discover \
            --top-level-directory ${GEOPM_SOURCE} \
            --start-directory ${GEOPM_SOURCE}/integration/service/test \
            --pattern 'test_*.py' \
            --verbose &>> test-service.log
    ERR=$?
fi
# TODO Rebuild the compute image again with the latest install_service.sh

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${UNINSTALL_COMMAND}

# Restore the "gold" version of the RPMs
set -x
uninstall_service.sh
install_service_gold.sh
set +x

if [ "${ERR}" -eq 0 ]; then
    echo "SUCCESS"
    exit 0
else
    echo "FAILURE" 1>&2
    exit -1
fi
