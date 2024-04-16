#!/bin/bash

set -ex

GEOPM_VERSION=$(cat ~/geopm/libgeopmd/VERSION)
INSTALL_COMMAND="sudo /usr/sbin/install_service.sh ${GEOPM_VERSION} ${USER}"

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${INSTALL_COMMAND}
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} grant_access.sh

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} systemctl status geopm
