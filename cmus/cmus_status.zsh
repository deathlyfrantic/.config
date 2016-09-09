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

__title=

output="$_artist - $_title$__status"
output=$(echo $output | sed -e 's/&/\&amp\;/g')
output=$(echo $output | sed -e 's/>/\&gt\;/g')
output=$(echo $output | sed -e 's/</\&lt\;/g')
output=$(echo $output | sed -e "s/'/\&apos\;/g")
output=$(echo $output | sed -e 's/"/\&quot\;/g')

~/Code/swaystag/swaystag.py block --name "music" --sort_order 1 --full_text "$output" --short_text "$_title" $remove
