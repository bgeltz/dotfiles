#!/bin/bash

# qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue:Score --sort State:Queue:JobID --reverse | grep -vE 'hold|queued'
# qstat --header=JobID:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue:Score --sort State:Queue:JobID --reverse | grep -vE 'hold|queued'
qstat --header=JobID:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue:Score --sort State:Score:Queue:JobID --reverse | grep -vE 'hold|debug'
