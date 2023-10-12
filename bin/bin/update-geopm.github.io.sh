#!/bin/bash

set -ex

# Source repo: https://github.com/geopm/geopm
# Website repo: https://github.com/geopm/geopm.github.io

cd ~/git/geopm
git clean -dfx
git fetch origin
git checkout dev
git reset --hard origin/dev
./autogen.sh
./doxygen_update.sh
cd service
./autogen.sh
./configure
make -j9 docs
cd ~/git/geopm.github.io
cp -rp ~/git/geopm/service/docs/build/html/* .
cp ~/git/geopm/json_schemas/* .
cp ~/git/geopm/service/json_schemas/* .
git add -A
git commit -sm'Update to version '$(cat ~/git/geopm/VERSION)
git push origin master

