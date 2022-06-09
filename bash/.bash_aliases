#!/bin/bash

# Apt related aliases
alias aptU="sudo apt update"
alias aptD="sudo apt dist-upgrade"
alias aptI="sudo apt install"
alias aptS="apt search"
alias aptR="sudo apt remove"

# Git related aliases
# Name of the current branch, or empty if there isn't one.
_current_branch_pretty ()
{
    local b=$(_current_branch) #From .stgit-completion.bash
    echo ${b:+(${b})}
}

delete_branch(){
    echo "Deleting branch ${1}..."
    git branch -D ${1}
    git push bgeltz-public --delete ${1}
}

glg(){
    git lg -${1-10} ${2}
}

ghist(){
    # https://stackoverflow.com/a/18767922
    git branch -vv --color=always | while read; do
        # The underscore is because the active branch is preceded by a '*', and
        # for awk I need the columns to line up. The perl call is to strip out
        # ansi colors; if you don't pass --color=always above you can skip this
        local branch=$(echo "_$REPLY" | awk '{print $2}' | perl -pe 's/\e\[?.*?[\@-~]//g')
        # git log fails when you pass a detached head as a branch name.
        # Hide the error and get the date of the current head.
        local branch_modified=$(git log -1 --format=%ci "$branch" 2> /dev/null || git log -1 --format=%ci)
        echo -e "$branch_modified $REPLY"
    # cut strips the time and timezone columns, leaving only the date
    done | sort -r | cut -d ' ' -f -1,4-
}

ppub(){
    if [ -n "$(_current_branch)" ]; then
        git push bgeltz-public $(_current_branch)
    else
        echo "Not on a git branch."
    fi
}

ppriv(){
    if [ -n "$(_current_branch)" ]; then
        git push bgeltz-private $(_current_branch)
    else
        echo "Not on a git branch."
    fi
}

ppubf(){
    if [ -n "$(_current_branch)" ]; then
        git push -f bgeltz-public $(_current_branch)
    else
        echo "Not on a git branch."
    fi
}

pprivf(){
    if [ -n "$(_current_branch)" ]; then
        git push -f bgeltz-private $(_current_branch)
    else
        echo "Not on a git branch."
    fi
}

ppubfd(){
    if [ -n "$(_current_branch)" ]; then
        git push -f bgeltz-public $(_current_branch):bgeltz-dev
    else
        echo "Not on a git branch."
    fi
}

upd(){
    if [ -n "$(_current_branch)" ]; then
        git reset --hard bgeltz-public/$(_current_branch)
    else
        echo "Not on a git branch."
    fi
}

update(){
    if [ -n "$(_current_branch)" ]; then
        git fetch origin
        git rebase origin/dev
    else
        echo "Not on a git branch."
    fi
}

reset_pr(){
    2>/dev/null git checkout -b pr-test
    git reset --hard origin/dev
}

get_pr(){
    git fetch -f origin pull/${1}/head:pr-${1}
    git checkout pr-${1}
    git rebase pr-test
    git checkout pr-test
    git reset --hard pr-${1}
}

wwi(){ # where was I
  vim -p $(git status --porcelain | awk '{print $2}')
}


# Git aliases
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias glist='for ref in $(git for-each-ref --sort=-committerdate --format="%(refname)" refs/heads/ refs/remotes ); do git log -n1 $ref --pretty=format:"%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n" | cat ; done | awk '"'! a["'$0'"]++' | head -n 20"
alias githist="git for-each-ref --sort=-committerdate refs/heads/ refs/remotes/ --format='%(HEAD) %(color:red)%(objectname:short)%(color:reset)|%(color:yellow)%(refname:short)%(color:reset)|%(contents:subject)|%(authorname) (%(color:green)%(committerdate:relative)%(color:reset))' | column -ts'|'"
alias save="git commit -a --amend --no-edit"

# Misc
h2d(){
  echo "ibase=16; $@"|bc
}

d2h(){
  echo "obase=16; $@"|bc
}

copy_logs(){
    TIMESTAMP=$(date +%F_%H%M); mkdir ~/public_html/misc_logs/${TIMESTAMP} && cp ${1} ~/public_html/misc_logs/${TIMESTAMP}
}

alias b='google-chrome --new-window 2>&1 /dev/null &'
alias ayfi='repo forall -c "git reset -q --hard HEAD && git clean -qfd" -j9'
alias rsy='repo sync -j5'
alias rst='repo status -j`nproc`'
alias beep='echo -en "\007"'
alias vi='vim'
alias disk_usage='du -sch -- * | sort -hr | head -n 11'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto  -h --group-directories-first'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -lF'
alias la='ls -AF'
alias l='ls -CLF'
alias lsd='ls -latrd'

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

