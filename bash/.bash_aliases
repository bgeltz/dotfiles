#!/bin/bash

# Apt related aliases
alias aptU="sudo apt-get update"
alias aptD="sudo apt-get dist-upgrade"
alias aptI="sudo apt-get install"
alias aptS="apt-cache search"
alias aptR="sudo apt-get remove"

# Git related aliases
# Name of the current branch, or empty if there isn't one.
_current_branch_pretty ()
{
    local b=$(_current_branch) #From .stgit-completion.bash
    echo ${b:+(${b})}
}

EMAILS='r=christopher.m.cantalupo@intel.com,r=diana.r.guttman@intel.com,r=brandon.baker@intel.com'
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
    if [ -n "$(_current_branch)" ]; then
        git push bgeltz-public $(_current_branch)
    else
        echo "Not on a git branch."
    fi
}

ppf(){
    if [ -n "$(_current_branch)" ]; then
        git push -f bgeltz-public $(_current_branch)
    else
        echo "Not on a git branch."
    fi
}

ppfd(){
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

# Git aliases
alias dev_review="git push origin HEAD:refs/for/dev%${EMAILS}"
alias gs='git status'
alias gd='git diff'
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
alias b='google-chrome --new-window'
alias c='pygmentize -g'
alias h='c /home/bgeltz/Documents/git_notes.txt'
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

# Cluster aliases
scancel_cleanup(){
    /usr/bin/scancel -s TERM ${1} && sleep 3 && /usr/bin/scancel ${1}
}
alias scancel=scancel_cleanup

copy_logs(){
    TIMESTAMP=$(date +%F_%H%M); mkdir ~/public_html/misc_logs/${TIMESTAMP} && cp ${1} ~/public_html/misc_logs/${TIMESTAMP}
}

