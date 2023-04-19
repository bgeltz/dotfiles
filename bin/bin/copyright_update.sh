#!/bin/bash

BEFORE='Copyright \(c\) 2015 - 2022, Intel Corporation'
AFTER='Copyright \(c\) 2015 - 2023, Intel Corporation'

# ag - https://github.com/ggreer/the_silver_searcher
ag --hidden --files-with-matches "${BEFORE}" | xargs sed -ri -e "s/${BEFORE}/${AFTER}/g"
