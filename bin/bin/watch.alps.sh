#!/bin/bash

#watch -n 1.0 "qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue -u $(whoami) ; echo ; ls -lta ${1}"
#watch -n 1.0 "qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue -u $(whoami) ; echo ; tail -n 20 ${1}"
watch -n 1.0 "qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue -u $(whoami) default; echo ; qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue Q.GEO_test ;"

