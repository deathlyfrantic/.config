#!/bin/zsh
while test $# -ge 2
do
	eval _$1='$2'
	shift
	shift
done

remove=""
if [[ $_status == "stopped" ]]
then
    remove="--remove"
elif [[ $_status == "playing" ]]
then
    __status=""
else
    __status=" [$_status]"
fi

output=$(fish -c "escape_for_pango '$_artist - $_title$__status'")

~/Code/swaystag/swaystag.py block --name "music" --sort_order 1 --full_text "$output" --short_text "$_title" $remove
