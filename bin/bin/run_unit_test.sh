#!/bin/bash

source ${HOME}/geopm/integration/config/build_env.sh
LD_LIBRARY_PATH=.libs:${LD_LIBRARY_PATH}

$GEOPM_GDB \
./test/.libs/geopm_test --gtest_filter=${1}
