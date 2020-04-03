#!/bin/bash

# rm .local/* - Do this manually for now
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
pip --version
pip install --user --ignore-installed -r ~/geopm/scripts/requirements.txt
rm get-pip.py

