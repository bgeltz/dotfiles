#!/bin/bash

source ${HOME}/geopm/integration/config/gnu_env.sh
GEOPM_SKIP_COMPILER_CHECK=yes source ${HOME}/geopm/integration/config/build_env.sh
GEOPM_SKIP_COMPILER_CHECK=yes GEOPM_RUN_TESTS=yes GEOPM_GLOBAL_CONFIG_OPTIONS="--enable-debug" ./integration/config/build.sh
