#!/bin/bash

qstat --header=JobID:JobName:User:WallTime:QueuedTime:RunTime:Nodes:State:Queue:Score --sort Score --reverse | grep -vE 'hold|running' | head -n 20
