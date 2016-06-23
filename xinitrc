[[ -f "$XDG_CONFIG_HOME"/x11/xresources ]] && xrdb -merge "$XDG_CONFIG_HOME"/x11/xresources
setxkbmap -option "ctrl:swapcaps"
exec i3
