#!/bin/bash
pigz -dc $1 | tar xvf -
# tar -xvf --use-compress-program=pigz ${1}
