#!/usr/bin/env zsh
_location=$(cat "$XDG_CONFIG_HOME/weather-location.txt")
_weather=$(weather "$_location")

if [[ $_weather != "" ]]
then
    ~/src/swaystag/swaystag.py block -n "weather" -f "Weather: $_weather" -st "$_weather" -o 997
fi
