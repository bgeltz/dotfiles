#!/bin/bash

EMAILS='r=christopher.m.cantalupo@intel.com,r=diana.r.guttman@intel.com,r=brandon.baker@intel.com'

# Apt related aliases
alias aptU="sudo apt-get update"
alias aptD="sudo apt-get dist-upgrade"
alias aptI="sudo apt-get install"
alias aptS="apt-cache search"
alias aptR="sudo apt-get remove"

# Build environment setup
alias s='module purge && module load gnu mvapich2 autotools'
alias si='module purge && module load intel mvapich2 autotools'

# Git related aliases
review(){
    echo "git push origin ${1}:refs/for/dev%${EMAILS}"
    git push origin ${1}:refs/for/dev%${EMAILS}
}

delete_branch(){
    echo "Deleting branch ${1}..."
    git branch -D ${1}
    git push bgeltz-public --delete ${1}
}

pp(){
    git push -f bgeltz-public $(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
}

alias dev_review="git push origin HEAD:refs/for/dev%${EMAILS}"
alias gs='git status'
alias gd='git diff'
alias glist='for ref in $(git for-each-ref --sort=-committerdate --format="%(refname)" refs/heads/ refs/remotes ); do git log -n1 $ref --pretty=format:"%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n" | cat ; done | awk '"'! a["'$0'"]++' | head -n 20"
alias githist="git for-each-ref --sort=-committerdate refs/heads/ refs/remotes/ --format='%(HEAD) %(color:red)%(objectname:short)%(color:reset)|%(color:yellow)%(refname:short)%(color:reset)|%(contents:subject)|%(authorname) (%(color:green)%(committerdate:relative)%(color:reset))' | column -ts'|'"
alias save="git commit -a --amend --no-edit"

# Misc
alias c='pygmentize -g'
alias h='c /home/bgeltz/Documents/git_notes.txt'
alias ayfi='repo forall -c "git reset -q --hard HEAD && git clean -qfd" -j9'
alias rsy='repo sync -j5'
alias rst='repo status -j`nproc`'
alias beep='echo -en "\007"'

# some more ls aliases
# https://unix.stackexchange.com/a/111639
mll() (
  if (($# == 0)); then
    dirs=() others=()
    shopt -s nullglob
    for f in *; do
      if [[ -d $f ]]; then
        dirs+=("$f")
      else
        others+=("$f")
      fi
    done
    set -- "${dirs[@]}" "${others[@]}"
  fi
  (($#)) && exec ls --color=auto  -h --group-directories-first -ldU -- "$@"
)

alias ll='ls -lF'
alias la='ls -AF'
alias l='ls -CLF'
