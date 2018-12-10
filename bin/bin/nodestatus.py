#!/usr/bin/env python

"""
This script takes a comma seperated list of nodes as input and will determine
what jobs (if any) are currently running on the nodes, and/or if the nodes are
being drained for a particular job.
"""

import sys
import subprocess
import re

def main(argv):
    """
    Usage:
        nodestatus.py <NODE_ID_1>
        nodestatus.py <NODE_ID_1>,<NODE_ID_2>,...
    """
    nodelist = argv[0].split(',')

    status = subprocess.check_output("nodelist -b {} | egrep 'reserved_jobid|drain_jobid|node_id'".format(argv[0]), shell=True)
    status = status.split('\n')
    jobids = []
    nodejob = {}
    nodedrain = {}
    nid = 0
    jid = 0
    for idx, line in enumerate(status):
        if line == '':
            continue

        if idx % 3 == 0:
            nid = re.sub(r'[^\d]+', '', line)
        elif idx % 3 == 1:
            jid = re.sub(r'[^\d]+', '', line)
            if jid:
                jobids.append(jid)
                nodejob[nid] = jid
            else:
                nodejob[nid] = 'FREE'
        elif idx % 3 == 2:
            jid = re.sub(r'[^\d]+', '', line)
            if jid:
                jobids.append(jid)
                nodedrain[nid] = jid
            else:
                nodedrain[nid] = 'FREE'

    for key, val in nodejob.iteritems():
        sys.stdout.write('nid {} is allocated to job {}. Draining for {}.\n'.format(key, val, nodedrain[key]))
        sys.stdout.flush()

    header = 'JobID:JobName:User:WallTime:QueuedTime:RunTime:TimeRemaining:Nodes:State:Queue:Score'
    status = subprocess.check_output('qstat --header={} {}'.format(header,' '.join(jobids)), shell=True)

    sys.stdout.write('\n{}\n'.format(status))
    sys.stdout.flush()

if __name__ == '__main__':
    main(sys.argv[1:])

