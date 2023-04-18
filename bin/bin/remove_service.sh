#!/bin/bash

set -ex

export REMOVE_COMMAND="sudo /usr/sbin/install_service.sh --remove"
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} ${REMOVE_COMMAND}
