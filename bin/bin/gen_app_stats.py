#!/usr/bin/env python

import geopmpy.io
import pandas
import sys

report_path = '*report'

collection = geopmpy.io.RawReportCollection(report_path)
df = collection.get_df()
edf = collection.get_epoch_df()
adf = collection.get_app_df()

df = df.set_index(['Agent', 'region'])
edf = edf.set_index(['Agent'])
adf = adf.set_index(['Agent'])

adf_field_list = ['runtime (sec)', 'network-time (sec)', 'package-energy (joules)', 'power (watts)']

with open('app_stats.log', 'w') as log:
    results = adf.groupby('Agent')[adf_field_list].describe().T
    log.write('{}\n\n'.format(results))
    sys.stdout.write('{}\n'.format(results))

import code
code.interact(local=dict(globals(), **locals()))

