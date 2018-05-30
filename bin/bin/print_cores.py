#!/usr/bin/env python

# This takes 3 commandline args: <CORES_PER_SOCKET> <NUM_SOCKETS> <NUM_HYPERTHREADS>
# It will then print the ranges of Linux CPU numbers for each group.

import sys

cores_per_socket = int(sys.argv[1])
sockets = int(sys.argv[2])
hyperthreads = int(sys.argv[3])

core = 0
core_lists = []
for x in range(sockets * hyperthreads):
    core_lists.extend([range(core, cores_per_socket * (x+1), 1)])
    core += cores_per_socket

for x in range(sockets):
    sys.stdout.write('Physical cores (socket {}): {} - {}\n'
                     .format(x+1, core_lists[x][0], core_lists[x][-1]))

for x in range(sockets):
    for y in range(hyperthreads - 1):
        index = sockets + y + x * (hyperthreads - 1)
        sys.stdout.write('HT {}     cores (socket {}): {} - {}\n'
                         .format(y+1, x+1, core_lists[index][0], core_lists[index][-1]))

