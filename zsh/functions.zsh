function set_title {
    local prefix=""
    local mode=0 # 1 = tab, 2 = window, 0 = both

    if [[ $SSH_CONNECTION != "" ]]; then
        prefix="[$USER@$HOST] "
    elif [[ $USER != "zandr" ]]; then
        prefix="[$USER] "
    fi

    print -n "\e]$mode;$prefix$1\a"
}

function precmd {
    local dir=${PWD/$HOME/\~}
    set_title "zsh $dir"
}

function preexec {
    set_title $*
}

function zshaddhistory {
    # don't save boring history
    local boring=(
        '^ls'
    )
    for i in $boring; do
        if [[ $1 =~ $i ]]; then
            return 1
        fi
    done
    return 0
}

function timer {
    if [[ $1 == "" ]]; then
        local secs=60
    else
        local secs=$1
    fi
    local pf=" %$(($COLUMNS / 2))s\r"
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
