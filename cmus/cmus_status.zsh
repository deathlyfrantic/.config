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
    status=""
else
    status=" [$_status]"
fi

output="$_artist - $_title$status"

~/Code/swaystag/swaystag.py block --name "music" --sort_order 1 --full_text "$output" --short_text "$_title" $remove
