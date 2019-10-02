#!/bin/bash

# HOST=theta
HOST=supermucng

set -x
rsync -avhe ssh --progress ${HOST}:${1} .
