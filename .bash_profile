#!/usr/bin/env bash
# set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ]; then
  PATH="${PATH}:${HOME}/bin"
fi
# set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/.local/bin" ]; then
  PATH="${HOME}/.local/bin:${PATH}"
fi
# include .bashrc if it exists
if [ -f "${HOME}/.bashrc" ]; then
  source "${HOME}/.bashrc"
fi

# global environments
HISTFILESIZE=10000
HISTTIMEFORMAT='%F %T '
HISTCONTROL=ignoreboth
HISTIGNORE="history"
