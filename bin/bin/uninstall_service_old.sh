#!/bin/bash

set -ex

UNINSTALL_COMMAND="sudo /usr/sbin/install_service_old.sh --remove"

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${UNINSTALL_COMMAND}

srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} systemctl status geopm
