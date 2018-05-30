#!/bin/bash
tar cf - ${1} | pigz -9 > ${1%/}.tgz
# tar -cvz --use-compress-program=pigz -f ${1/%/} ${1} 
