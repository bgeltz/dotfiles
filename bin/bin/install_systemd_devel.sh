#!/bin/bash

set -e

INSTALL_LOCATION=${HOME}/build/systemd
if [ -d ${INSTALL_LOCATION}/include ]; then
    echo "Install location ${INSTALL_LOCATION} already populated.  Stopping."
    exit 1
fi

# 15.3
RPM_URL=http://download.opensuse.org/distribution/leap/15.3/repo/oss/x86_64/systemd-devel-246.13-5.1.x86_64.rpm
# 15.4
# RPM_URL=http://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/systemd-devel-249.11-150400.6.8.x86_64.rpm

wget -e robots=off -nd -np ${RPM_URL}
rpm2cpio $(ls systemd-devel*rpm) | cpio -idmv

if [ ! -d ${INSTALL_LOCATION} ]; then
    mkdir -p ${INSTALL_LOCATION}
fi
mv usr/include ${INSTALL_LOCATION}
mv usr/lib64 ${INSTALL_LOCATION}
ln -fs /usr/lib64/libsystemd.so.0 ${INSTALL_LOCATION}/lib64/libsystemd.so

echo -e "\nPrior to running build.sh, run the following:\n"
echo 'export CPPFLAGS="-I${HOME}/build/systemd/include'
echo 'export LDFLAGS="-L${HOME}/build/systemd/lib64"'

