#!/usr/bin/env python3

import sys
import pandas
#  from io import StringIO
import os
from geopmpy.io import Trace

pandas.set_option('display.width', 0)
pandas.set_option('display.max_colwidth', 30)
pandas.set_option('display.max_rows', None)

#  df = pandas.read_csv(sys.argv[1], sep='|', skiprows=5)
df = Trace(sys.argv[1])

#  irs = df[1674:1678]
irs = df
aa = irs[['TIME', 'REGION_HASH']]

bb = irs.filter(like='REGION_HASH-core')
aa = aa.join(bb)
bb = irs.filter(like='PERF_CTL:FREQ-core')
aa = aa.join(bb)
bb = irs.filter(like='PERF_STATUS:FREQ-core')
aa = aa.join(bb)

# Write all the data and do not wrap lines
file_name = 'temp.txt'
if not os.path.exists(file_name):
    with pandas.option_context('display.max_columns', None, 'display.width', None):
        with open('temp.txt', 'w') as log:
            log.write('{}'.format(aa))
            #  log.write('{}'.format(aa.T))

#  a2a_df = df.loc[df['REGION_HASH'] == '0x3ddc81bf']
#  df.loc[df['REGION_HASH'] == '0x3ddc81bf'].filter(like='MSR::PERF_CTL:FREQ-core').describe().T
#  df.loc[df['REGION_HASH'] == '0x3ddc81bf'].filter(like='MSR::PERF_CTL:FREQ-core').describe().T['mean']
#  mm = df.loc[df['REGION_HASH'] == '0x3ddc81bf'].filter(like='MSR::PERF_STATUS:FREQ-core').describe().T['mean'].mean()
#  sys.stdout.write(f'\nall2all achieved core frequency, mean of means: {mm}\n\n')

import code
code.interact(local=dict(globals(), **locals()))

#########
# df[df['REGION_HASH'] == '0x3ddc81bf'][:10]

# aa = df[1674:1678].filter(like='REGION_HASH-core')

# bb = df[1674:1678].filter(items=['TIME', 'REGION_HASH'])
# bb = df[1674:1678][['TIME', 'REGION_HASH']]

# bb.join(aa)

# Get regions
# a.index.unique(level='region')

