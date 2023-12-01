#!/bin/bash

set -ex

INSTALL_COMMAND="sudo /usr/sbin/install_service.sh 3.0.0 gold_rpms"

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${INSTALL_COMMAND}
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} /home/test/bin/grant_access.sh

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} systemctl status geopm
