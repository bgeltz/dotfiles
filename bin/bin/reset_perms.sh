#!/bin/bash

chmod -R o+r ${1}/*
find ${1} -type d -print0 | xargs -0 chmod 755

