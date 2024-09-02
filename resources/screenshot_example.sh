#!/usr/bin/env bash

# Use bash-completion, if available
# shellcheck source=/dev/null
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi

# ^C no longer shows on C-c keypress
bind "set echo-control-characters off"

# Command history search - Up & Down Arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Move forward/backward by word - Alt + Left or Right Arrows
bind '"\e[1;5D": backward-word'
bind '"\e[1;5C": forward-word'

alias cleanHistory='sort -u "$HOME/.config/bash/history" -o "$HOME/.config/bash/history"'
if [[ ! -f "$HOME"/.config/bash/ ]]; then
    mkdir -pv "$HOME"/.config/bash/
    export HISTFILE="$HOME/.config/bash/history"
else
    export HISTFILE="$HOME/.config/bash/history"
fi
# Expand the history size
export HISTSIZE=10000000
export HISTFILESIZE=10000000
# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace:ignoreboth
# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize
# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
# PROMPT_COMMAND='history -a'
# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon
