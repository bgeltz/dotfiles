#!/bin/bash

QUEUE=Q.GEO_test
# QUEUE=R.GEO_res1

#watch -n 1.0 "qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue -u $(whoami) ; echo ; ls -lta ${1}"
watch -n 3.0 "qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue --sort Queue:JobID --reverse -u ${USER} ;"
#watch -n 1.0 "qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue -u $(whoami); echo ; qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue ${QUEUE} ;"

