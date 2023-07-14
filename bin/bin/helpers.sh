#!/bin/bash

reset_pr_test(){
    git switch -C pr-test
    git reset --hard origin/dev
}

get_pr(){
    git fetch -f origin pull/${1}/head:pr-${1}
    git checkout pr-${1}
    git rebase pr-test
    git checkout pr-test
    git reset --hard pr-${1}
}

