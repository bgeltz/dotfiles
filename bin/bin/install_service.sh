#!/bin/bash

set -ex

export GEOPM_VERSION=$(cat ~/geopm/service/VERSION)
export INSTALL_COMMAND="sudo /usr/sbin/install_service.sh ${GEOPM_VERSION} ${USER}"

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${INSTALL_COMMAND}
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ~bgeltz/bin/grant_access.sh

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} systemctl status geopm
