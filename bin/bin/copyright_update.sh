#!/bin/bash

BEFORE='Copyright \(c\) 2015, 2016, 2017, 2018, 2019, 2020, 2021, Intel Corporation'
AFTER='Copyright \(c\) 2015 - 2021, Intel Corporation'

# ag - https://github.com/ggreer/the_silver_searcher
ag --hidden --files-with-matches "${BEFORE}" | xargs sed -ri -e "s/${BEFORE}/${AFTER}/g"
