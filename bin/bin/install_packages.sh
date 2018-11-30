#!/bin/bash

# WIP Install all python packages into virtualenv

if [ -x "$(command -v pip)" ]; then
    echo "pip exists"
    # Check for outdated packages, including pip itself
    # pip list --user --outdated

    # Verify virtual env is installed
    # python -c "import virtualenv"
    # check rc
else
    echo "pip doesn't exist"
    exit 1
    # https://pip.pypa.io/en/stable/installing/
    # curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    # python get-pip.py --user
fi

if [ ! -z ${DARSHAN_PRELOAD} ]; then
    echo "Error: Darshan was detected in your environment and is known to conflict with GEOPM."
    echo "Run \"module unload darshan\"."
    exit 1
fi

TMP_DIR=${HOME}/tmp/pydeps
echo "Removing ${TMP_DIR}..."
rm -fr ${TMP_DIR}

virtualenv ${TMP_DIR}
source ${TMP_DIR}/bin/activate

# MIC_FLAG='-xCORE-AVX2'
# export CC="cc ${MIC_FLAG} -dynamic"
# export CXX="CC ${MIC_FLAG} -dynamic"
# The only way I've gotten psutil to load is with:
#   module swap PrgEnv-intel PrgEnv-gnu
#   module unload darshan
#   Then run this.

pip install --ignore-installed --no-cache-dir pandas natsort matplotlib cycler tables psutil numexpr bottleneck

deactivate

echo "Deps installed into ${TMP_DIR}/lib/python2.7/site-packages"
