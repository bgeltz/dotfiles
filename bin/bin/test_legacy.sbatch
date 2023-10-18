#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00
#SBATCH --reboot

loop_iteration=${SLURM_ARRAY_TASK_ID:-0}
mkdir ${loop_iteration}
cd ${loop_iteration}

install_service.sh

source ${HOME}/geopm/integration/config/run_env.sh

if [ "${1}" == "gnu" ]; then
    # Set LD_LIBRARY_PATH and PATH since the GNU run is performed without 'make install'
    module purge && module load gnu9 mpich autotools ccache
    export LD_LIBRARY_PATH=${GEOPM_SOURCE}/service/.libs:${GEOPM_SOURCE}/.libs:${LD_LIBRARY_PATH}
    export PATH=${GEOPM_SOURCE}/service/.libs:${GEOPM_SOURCE}/.libs:${PATH}
    export PYTHONPATH=${GEOPM_SOURCE}/scripts:${GEOPM_SOURCE}/service:${PYTHONPATH}
else
    # For everything else, the default modules are fine and an install was performed
    module purge && module load ohpc
    while [ ! -d "${GEOPM_INSTALL}" ] ; do
        echo "Waiting for GEOPM_INSTALL..."
        sleep 30
    done
fi

python3 -m unittest discover \
        --top-level-directory ${GEOPM_SOURCE} \
        --start-directory ${GEOPM_SOURCE}/integration/test \
        --pattern 'test_*.py' \
        --verbose
rc=$?

if [ "${rc}" -eq 0 ]; then
    echo "${0}: Continuing iteration ${loop_iteration} service tests..." > >(tee -a ${LOG_FILE})

    python3 -m unittest discover \
            --top-level-directory ${GEOPM_SOURCE} \
            --start-directory ${GEOPM_SOURCE}/service/integration/test \
            --pattern 'test_*.py' \
            --verbose
    rc=$?
fi

# Restore the "gold" version of the RPMs
set -x
uninstall_service.sh
install_service_gold.sh
set +x

echo "Loop iteration $loop_iteration rc=$rc at $(date)"
if [ "${rc}" -eq 0 ]; then
        touch ../.tests_complete.${loop_iteration}
else
        touch ../.tests_failed.${loop_iteration}
fi
exit ${rc}
