#!/usr/bin/env python

import sys
import pandas
from io import StringIO

data = sys.stdin.read()
a = pandas.read_csv(StringIO(data), header=None)
sys.stdout.write('{}\n'.format(a.describe()))

# Get regions
# a.index.unique(level='region')

#  import code # Doesn't work after a pipe, it's not interactive
#  code.interact(local=dict(globals(), **locals()), banner="Data in 'a'.")

