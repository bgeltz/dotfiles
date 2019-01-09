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

TMP_DIR=${HOME}/tmp/pydeps

virtualenv ${TMP_DIR}
source ${TMP_DIR}/bin/activate

pip install pandas natsort matplotlib cycler tables psutil numexpr bottleneck

deactivate

echo "Deps installed into ${TMP_DIR}/lib/python2.7/site-packages"

