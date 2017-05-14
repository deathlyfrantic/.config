#!/bin/zsh

_logfile="$XDG_CACHE_HOME"/sway-debug.log
sway -d 2> $_logfile

if [[ $? != 0 ]]; then
    _time=$(date +'%Y%m%d%H%M%S')
    cp $_logfile ~/sway-crash-$_time.log
fi
