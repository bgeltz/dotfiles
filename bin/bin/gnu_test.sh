#!/bin/bash

set -e

source ${HOME}/venv/bin/activate

export GEOPM_SKIP_COMPILER_CHECK=yes
source ${HOME}/geopm/integration/config/gnu_env.sh
source ${HOME}/geopm/integration/config/build_env.sh

GEOPM_GLOBAL_CONFIG_OPTIONS="--enable-debug" GEOPM_RUNTIME_CONFIG_OPTIONS="--disable-fortran --disable-mpi" \
./integration/config/build.sh
