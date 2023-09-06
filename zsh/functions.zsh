function set_title {
    local prefix=""
    local mode=0 # 1 = tab, 2 = window, 0 = both

    if [[ $SSH_TTY != "" ]]; then
        prefix="[$USER@$HOST] "
    elif [[ $USER != "zandr" ]]; then
        prefix="[$USER] "
    fi

    print -n "\e]$mode;$prefix$1\a"
}

function precmd {
    local dir=${PWD/$HOME/\~}
    set_title "zsh $dir"
    echo "${fg_bright[black]}$(repeat $COLUMNS printf -- '-%.0s')$reset_color"
}

function preexec {
    set_title "$@"
}
