[[ -f "$XDG_CONFIG_HOME"/x11/xresources ]] && xrdb -merge "$XDG_CONFIG_HOME"/x11/xresources
exec i3
