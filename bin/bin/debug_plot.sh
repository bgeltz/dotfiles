#!/usr/bin/env python3

import matplotlib.pyplot as plt
from geopmpy.io import Trace

tt1 = Trace('test_trace.trace-mcfly1')
tt2 = Trace('test_trace.trace-mcfly2')
tt3 = Trace('test_trace.trace-mcfly3')
tt4 = Trace('test_trace.trace-mcfly4')

plot.plot(tt1['TIME'], tt1['REGION_HASH'])
plot.savefig('test_trace.png')
