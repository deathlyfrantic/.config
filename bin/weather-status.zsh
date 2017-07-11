_location=$(kv get weather-location)
_weather=$(weather "$_location" 10)
_short=$(echo $_weather | cut -d' ' -f1)
stag block -n "weather" -f "$_weather" -st "$_short" -o 997
