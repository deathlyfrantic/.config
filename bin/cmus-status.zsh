#!/bin/zsh

while test $# -ge 2
do
    eval _$1='$2'
    shift
    shift
done

_remove=""
if [[ $_status == "stopped" ]]; then
    _remove="--remove"
elif [[ $_status == "playing" ]]; then
    __status=""
else
    __status=" [$_status]"
fi

_output="$_artist - $_title$__status"
stag block -n "music" -o 10 -f "$_output" -st "$_title" $_remove
