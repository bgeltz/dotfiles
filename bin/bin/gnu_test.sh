#!/bin/bash

export GEOPM_SKIP_COMPILER_CHECK=yes
source ${HOME}/geopm/integration/config/gnu_env.sh
source ${HOME}/geopm/integration/config/build_env.sh

# GEOPM_SKIP_COMPILER_CHECK=yes GEOPM_RUN_TESTS=yes GEOPM_GLOBAL_CONFIG_OPTIONS="--enable-debug" ./integration/config/build.sh

GEOPM_GLOBAL_CONFIG_OPTIONS="--enable-debug" \
GEOPM_BASE_CONFIG_OPTIONS="--with-bash-completion-dir=${GEOPM_INSTALL}"
./integration/config/build.sh
