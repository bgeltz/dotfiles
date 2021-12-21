#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00
#SBATCH -o /home/test-service/test-service.sbatch.log
#SBATCH -e /home/test-service/test-service.sbatch.log

#export GEOPM_RUN_LONG_TESTS=TRUE
unset GEOPM_RUN_LONG_TESTS

export GEOPM_SOURCE=/home/test-service/geopm-cmcantal
export GEOPM_INSTALL=/home/test-service/build/geopm-cmcantal
export LD_LIBRARY_PATH=${GEOPM_INSTALL}/lib:${LD_LIBRARY_PATH}
export PYTHONPATH=${GEOPM_SOURCE}/integration:${GEOPM_INSTALL}/lib/python3.6/site-packages:${PYTHONPATH}
export PATH=${GEOPM_INSTALL}/bin:${PATH}
GEOPM_VERSION=$(cat ${GEOPM_SOURCE}/service/VERSION)

# Install geopm-service RPMs
INSTALL_COMMAND="sudo /usr/sbin/install_service.sh ${GEOPM_VERSION} ${USER}"
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} -n ${SLURM_NNODES} ${INSTALL_COMMAND}
python3 $GEOPM_SOURCE/integration/test --verbose
if [ $? -eq 0 ]; then
    echo "SUCCESS"
    exit 0
else
    echo "FAILURE" 1>&2
    exit -1
fi
