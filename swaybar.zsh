# janky script to generate swaybar
muted () {
    local muted="$(pactl list sinks | grep Mute: | sed -e 's/.*Mute: //')"
    if [[ $muted == "no" ]]; then
        return 0
    else
        return 1
    fi
}

headphones () {
    local headphones="$(pactl list sinks | grep Headphones | sed -e 's/.*, //')"
    if [[ $headphones == "available)" ]]; then
        return 1
    else
        return 0
    fi
}

volume () {
    local volume="$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"
    muted
    if [[ $? == 1 ]]; then
        volume="muted"
    fi
    echo "Volume: $volume"
}

song_info () {
    local artist="$(playerctl metadata artist)"
    local title="$(playerctl metadata title)"
    if [[ -a ~/dotfiles/cmus-status.txt ]]; then
        local info=$(<~/dotfiles/cmus-status.txt)
        if [[ $info == "[stopped]" ]]; then
            echo ""
        else
            echo "$info"
        fi
    elif [[ $artist != "" && $title != "" ]]; then
        echo "$artist - $title"
    fi

}

calendar () {
    date +'%a %m/%d/%Y'
}

clock () {
    date +'%r'
}

escape_for_pango () {
    local string="$1"
    string=$(echo $string | sed -e 's/&/\&amp\;/g')
    string=$(echo $string | sed -e 's/>/\&gt\;/g')
    string=$(echo $string | sed -e 's/</\&lt\;/g')
    string=$(echo $string | sed -e "s/'/\&apos\;/g")
    string=$(echo $string | sed -e 's/"/\&quot\;/g')
    echo $string
}

segment () {
    local name=$1
    local text=$(escape_for_pango "$($1)")
    if [[ $text != "" ]]; then
        echo "{\"name\": \"$name\","
        echo "\"full_text\": \"$text\","
        echo "\"short_text\": \"$text\","
        echo "\"separator_block_width\": 21,"
        echo "\"markup\": \"pango\"},"
    fi
}

echo '{ "version": 1 }'
echo '['
while true; do
    echo ",["
    segment "song_info"
    segment "volume"
    segment "calendar"
    segment "clock"
    echo "]"
    sleep 1
done
