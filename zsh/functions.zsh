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
    echo $fg_bright[black]$(repeat $COLUMNS printf -- '-%.0s')$reset_color
}

function preexec {
    set_title $*
}

function zshaddhistory {
    # don't save boring history
    local boring=(
        '^ls '
        '^ls$'
        '^ll '
        '^ll$'
    )
    for i in $boring; do
        if [[ $1 =~ $i ]]; then
            return 1
        fi
    done
    return 0
}

function timer {
    local secs=${1:-60}
    local pf=" %$(($COLUMNS / 2))s\e[0K\r"
    printf "\n"
    for i in $(seq $secs 1); do
        printf $pf $i
        sleep 1
    done
    printf "$pf\n\n" "DONE"
    tput bel
}

function nofail {
    false
    until [[ $? -eq 0 ]]; do
        $*
    done
}
