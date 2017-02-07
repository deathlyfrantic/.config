#!/usr/bin/env zsh
_location=$(cat "$XDG_CONFIG_HOME/weather-location.txt")
_weather=$(weather "$_location" 10)
~/src/swaystag/swaystag.py block -n "weather" -f "$_weather" -st "$_weather" -o 997
