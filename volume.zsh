if [[ $1 == "up" ]]
then
    pactl set-sink-volume 0 +5%
elif [[ $1 == "down" ]]
then
    pactl set-sink-volume 0 -5%
fi

volume="$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"
muted="$(pactl list sinks | grep Mute: | sed -e 's/.*Mute: //')"
if [[ $muted == "yes" ]]; then
    volume="muted"
fi

~/Code/swaystag/swaystag.py block --name "volume" --full_text "Volume: $volume" --short_text "$volume" --sort_order 500
