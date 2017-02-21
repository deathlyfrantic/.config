#!/usr/bin/env zsh
_location=$(cat "$XDG_CONFIG_HOME/weather-location.txt")
_weather=$(weather "$_location" 10)
swaystag block -n "weather" -f "$_weather" -st "$_weather" -o 997
