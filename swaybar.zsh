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
    echo "Volume $volume"
}

volume_icon () {
    local volume="$(volume)"
    local icon=""
    headphones
    if [[ $? == 1 ]]; then
        # icon=""
        icon='\uf025'
    elif [[ $volume -lt 20 ]]; then
        # icon=""
        icon='\uf026'
    elif [[ $volume -lt 40 ]]; then
        # icon=""
        icon='\uf027'
    else
        # icon=""
        icon='\uf028'
    fi
    echo $icon
}

song_info () {
    local artist="$(playerctl metadata artist)"
    local title="$(playerctl metadata title)"
    if [[ $artist != "" && $title != "" ]]; then
        echo "$artist - $title"
    fi
}

song_info_icon () {
    local status="$(playerctl status)"
    local icon=""
    if [[ $status == "Playing" ]]; then
        # icon="⏵"
        icon='u\23f5'
    elif [[ $status == "Paused" ]]; then
        # icon="⏸"
        icon='\u23f8'
    else
        # icon="⏹"
        icon='\u23f9'
    fi
    echo $icon
}

calendar () {
    date +'%a %m/%d/%Y'
}

calendar_icon () {
    # echo ""
    echo '\uf073'
}

clock () {
    date +'%r'
}

clock_icon () {
    # echo ""
    echo '\uf017'
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
    # local icon=$("$1_icon")
    if [[ $text != "" ]]; then
        echo "{\"name\": \"$name\","
        # echo "\"full_text\": \"<span font_family='FontAwesome'>$icon</span> $text\","
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
