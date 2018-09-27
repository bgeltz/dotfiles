#!/bin/bash
pigz -dc $1 | tar xvf -
# tar -xvf --use-compress-program=pigz ${1}
# tar -xvf --use-compress-program=pigz 266912-nekbone-256node-7rank-9thread-2018-09-01_0920.tgz --wildcards "*report"
