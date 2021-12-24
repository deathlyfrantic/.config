#!/bin/sh

if [ -x /usr/local/bin/zsh ]; then
    # this is where zsh is on intel macs
    /usr/local/bin/zsh "$@"
elif [ -x /opt/homebrew/bin/zsh ]; then
    # homebrew puts files in a different place on apple silicon macs ¯\_(ツ)_/¯
    /opt/homebrew/bin/zsh "$@"
else
    # zsh isn't installed from homebrew, so use the built-in one
    /usr/bin/zsh "$@"
fi
