#!/usr/bin/env python

import geopmpy.io
import pandas
import sys

report_path = '*report'

collection = geopmpy.io.RawReportCollection(report_path)
df = collection.get_df()
edf = collection.get_epoch_df()
adf = collection.get_app_df()

mhz = lambda x : int(x / 1e6)
df['FREQ_DEFAULT'] = df['FREQ_DEFAULT'].apply(mhz) # Convert frequency to MHz for readability
adf['FREQ_DEFAULT'] = adf['FREQ_DEFAULT'].apply(mhz) # Convert frequency to MHz for readability

df = df.set_index(['region', 'FREQ_DEFAULT'])
df.index = df.index.set_names('req_freq', level='FREQ_DEFAULT')
adf = adf.set_index(['FREQ_DEFAULT'])
adf.index = adf.index.set_names('req_freq')

df_field_list = ['count', 'frequency (%)', 'frequency (Hz)', 'runtime (sec)', 'sync-runtime (sec)', 'network-time (sec)', 'package-energy (joules)', 'power (watts)']
means_df = df.groupby(['region', 'req_freq'])[df_field_list].mean()

adf_field_list = ['runtime (sec)', 'network-time (sec)', 'package-energy (joules)', 'power (watts)']
means_adf = adf.groupby(['req_freq'])[adf_field_list].mean()

# Sort first by region alpha order, then decending by frequency
means_df = means_df.sort_index(level=['region', 'req_freq'], ascending=[True, False])
means_adf = means_adf.sort_index(level='req_freq', ascending=False)

with open('region_mean_stats.log', 'w') as log:
    log.write('Per-region means (all nodes)\n')
    log.write('-' * 80 + '\n')
    for (region), ldf in means_df.groupby('region'):
        log.write('{}\n\n'.format(ldf))
    log.write('-' * 80 + '\n')
    log.write('Application totals means (all nodes)\n')
    log.write('{}\n\n'.format(means_adf))

#  import code
#  code.interact(local=dict(globals(), **locals()))

