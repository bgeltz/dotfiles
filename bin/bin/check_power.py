#!/usr/bin/env python

import geopmpy.io
import pandas
import sys

report_path = '*report'

collection = geopmpy.io.RawReportCollection(report_path)
edf = collection.get_epoch_df()
edf = edf.set_index(['Agent', 'POWER_PACKAGE_LIMIT_TOTAL', 'Profile', 'host'])
edf.index = edf.index.set_names('Iteration', level='Profile')
edf.index = edf.index.set_names('power_budget', level='POWER_PACKAGE_LIMIT_TOTAL')

node_count = len(edf.index.unique('host'))
iteration_count = len(edf.index.unique('Iteration'))

#  with open('analysis.log', 'w') as log:
#      results = edf.groupby(['Agent', 'power_budget'])['power (watts)'].describe()
#      #  sys.stdout.write('Epoch Statistics for {} nodes over {} iteration(s)\n'.format(node_count, iteration_count))

#      log.write('-' * 80 + '\n')
#      log.write('Epoch Statistics for {} nodes over {} iteration(s): power (watts)\n'.format(node_count, iteration_count))
#      log.write('-' * 80 + '\n\n')
#      log.write('{}\n'.format(results))

field_list = ['count', 'package-energy (joules)', 'frequency (%)', 'network-time (sec)', 'runtime (sec)', 'sync-runtime (sec)', 'power (watts)']

# Detailed stats
with open('power_details.log', 'w') as log:
    for (power_budget, agent), df in edf.groupby(['power_budget', 'Agent']):
        log.write('-' * 80 + '\n')
        log.write('{} W: Agent = {}\n'.format(power_budget, agent))
        log.write('{}\n'.format(df[field_list].describe()))

# Mean stats
with open('power_means.log', 'w') as log:
    results = edf.groupby(['Agent', 'power_budget'])[field_list].mean()
    results = results.sort_index(level=['Agent', 'power_budget'], ascending=[False, False])
    log.write('=' * 80 + '\n')
    log.write('\n{}\n\n'.format(results))

    #Calculate runtime improvements
    improvement_fields = ['package-energy (joules)', 'sync-runtime (sec)']
    a = edf.xs(('power_governor'))[improvement_fields].groupby('power_budget').mean()
    b = edf.xs(('power_balancer'))[improvement_fields].groupby('power_budget').mean()
    improvement = (a - b) / a
    improvement = improvement.sort_index(ascending=False)
    log.write('Balancer vs. Governor Improvement:\n\n{}\n\n'.format(improvement))


