#!/bin/bash

set -e

DOWNLOAD_DIR=${HOME}/downloads
ARCHIVE=stow-2.2.2.tar.gz

if [ ! -d "${DOWNLOAD_DIR}" ]; then
    mkdir -p ${DOWNLOAD_DIR}
fi

pushd ${DOWNLOAD_DIR}
wget http://ftp.gnu.org/gnu/stow/${ARCHIVE}
tar zxvf ${ARCHIVE}
cd stow-2.2.2
./configure --prefix=${HOME}/build/stow
make -j9
make install
export PATH=${HOME}/build/stow/bin:${PATH}
popd

