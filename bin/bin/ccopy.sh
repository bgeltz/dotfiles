#!/bin/bash

# HOST=theta
# HOST=supermucng

set -x
echo "rsync -avhe ssh --progress ${1}:${2} ."
rsync -avhe ssh --progress ${1}:${2} .
