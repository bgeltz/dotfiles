#!/bin/bash

set -x

rsync -avhe ssh --progress theta:/projects/intel/geopm-home/shared/output/${1} .
