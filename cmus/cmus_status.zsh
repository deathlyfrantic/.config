#!/bin/zsh
escape_for_pango () {
    local string="$1"
    string=$(echo $string | sed -e 's/&/\&amp\;/g')
    string=$(echo $string | sed -e 's/>/\&gt\;/g')
    string=$(echo $string | sed -e 's/</\&lt\;/g')
    string=$(echo $string | sed -e "s/'/\&apos\;/g")
    string=$(echo $string | sed -e 's/"/\&quot\;/g')
    echo $string
}

while test $# -ge 2
do
    eval _$1='$2'
    shift
    shift
done

_remove=""
if [[ $_status == "stopped" ]]
then
    _remove="--remove"
elif [[ $_status == "playing" ]]
then
    __status=""
else
    __status=" [$_status]"
fi

_output=$(escape_for_pango "$_artist - $_title$__status")
~/Code/swaystag/swaystag.py block -n "music" -o 1 -f "$_output" -st "$_title" $_remove
