#!/bin/bash

set -x

rsync -avhe ssh --progress theta:${1} .
