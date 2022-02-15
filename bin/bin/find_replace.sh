#!/bin/bash

BEFORE="${1}"
AFTER="${2}"

# ag - https://github.com/ggreer/the_silver_searcher
ag --hidden --files-with-matches "${BEFORE}" | xargs sed -ri -e "s/${BEFORE}/${AFTER}/g"
