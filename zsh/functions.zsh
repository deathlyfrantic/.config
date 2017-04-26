function escape_for_pango {
    echo "$1" \
        | sed -e 's/&/\&amp\;amp\;/g' \
        | sed -e 's/>/\&gt\;/g' \
        | sed -e 's/</\&lt\;/g' \
        | sed -e "s/'/\&apos\;/g" \
        | sed -e 's/"/\&quot\;/g'
}

function set_title {
    local prefix=""

    if [[ $SSH_CONNECTION != "" ]]; then
        prefix="[$USER@$HOST] "
    elif [[ $USER != "zandr" && $USER != "zmartin" ]]; then
        prefix="[$USER] "
    fi

    print -n "\e]2;$prefix$1\a"
}

function precmd {
    local dir=${PWD/$HOME/\~}
    set_title "zsh $dir"
}

function preexec {
    set_title $*
}

function mkcd {
    mkdir -p $1 && cd $1
}

function venv_prompt {
    if [[ -n "$VIRTUAL_ENV" ]];
    then
        local vp=(
            "%{$reset_color%}["
            "%{$fg_bold[green]%}"
            "$(basename $VIRTUAL_ENV)"
            "%{$reset_color%}] "
            "%{$fg_bold[black]%}::"
            "%{$reset_color%} "
        )

        for i in $vp;
        do
            echo -n $i
        done
    fi
}
