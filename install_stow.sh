#!/bin/bash

set -e

MIRROR=https://mirrors.kernel.org/gnu/stow
DOWNLOAD_DIR=${HOME}/downloads
STOW_VERSION=stow-2.3.1
ARCHIVE=${STOW_VERSION}.tar.gz

if [ ! -d "${DOWNLOAD_DIR}" ]; then
    mkdir -p ${DOWNLOAD_DIR}
fi

pushd ${DOWNLOAD_DIR}
wget ${MIRROR}/${ARCHIVE}
tar zxvf ${ARCHIVE}
cd ${STOW_VERSION}
./configure --prefix=${HOME}/build/stow
make -j9
make install
export PATH=${HOME}/build/stow/bin:${PATH}
popd

