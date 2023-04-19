#!/bin/bash

# https://rabexc.org/posts/pitfalls-of-ssh-agents

ssh-add -l &>/dev/null
RC=${?}
if [ "${RC}" == 2 ]; then # Command failed, no agent or not sourced
  test -r ~/.ssh-agent && \
    eval "$(<~/.ssh-agent)" >/dev/null

  ssh-add -l &>/dev/null
  if [ "$?" == 2 ]; then # Sourced, but not started
    (umask 066; ssh-agent > ~/.ssh-agent)
    eval "$(<~/.ssh-agent)" >/dev/null
    ssh-add ${GH_KEY}
  fi
elif [ "${RC}" == 1 ]; then # Agent OK but no keys added
    echo "Re-adding GH_KEY..."
    ssh-add ${GH_KEY}
fi
