#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00
#SBATCH -o test-service.sbatch.%j.log
#SBATCH -e test-service.sbatch.%j.err

source ${HOME}/geopm/integration/config/run_env.sh

#export GEOPM_RUN_LONG_TESTS=TRUE
unset GEOPM_RUN_LONG_TESTS

GEOPM_VERSION=$(cat ${GEOPM_SOURCE}/service/VERSION)

# Install geopm-service RPMs
INSTALL_COMMAND="sudo /usr/sbin/install_service.sh ${GEOPM_VERSION} ${USER}"
UNINSTALL_COMMAND="sudo /usr/sbin/install_service.sh --remove"
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${INSTALL_COMMAND}
python3 -m unittest discover \
        --top-level-directory ${GEOPM_SOURCE} \
        --start-directory ${GEOPM_SOURCE}/integration/test \
        --pattern 'test_*.py' \
        --verbose >& test-service.log
ERR=$?
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${UNINSTALL_COMMAND}
if [ "${ERR}" -eq 0 ]; then
    echo "SUCCESS"
    exit 0
else
    echo "FAILURE" 1>&2
    exit -1
fi
