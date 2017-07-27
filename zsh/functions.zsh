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

function set_up_prompt {
    local _user="%{$fg[blue]%}%n"
    local _at="%{$fg_bold[blue]%}@%{$reset_color%}"
    local _dot=" %{$fg_bold[black]%}::%{$reset_color%} "
    local _host="%{$fg[blue]%}%m"
    local _path='%{$fg[white]%}${${(%):-%~}//\//%{$fg_bold[black]%\}/%{$reset_color%\}}'
    local _green=$(echo -e '\e[38;2;138;226;52m')
    local _base="$_path%(!.%{$fg_bold[red]%}.%{$_green%}) $%{$reset_color%} "

    if [[ $SSH_CONNECTION != '' ]]; then
        PROMPT=$_user$_at$_host$_dot$_base
    elif [[ $USER != 'zandr' ]]; then
        PROMPT=$_user$_dot$_base
    else
        PROMPT=$_base
    fi

    RPROMPT="%{$reset_color%}%D{%H}%{$fg_bold[black]%}:%{$reset_color%}%D{%M}%{$fg_bold[black]%}:%{$reset_color%}%D{%S}"

    if [[ -x $(which gitprompt 2> /dev/null) ]]; then
        RPROMPT='${$(gitprompt)} '$RPROMPT
    fi

    RPROMPT='${$(venv_prompt)}'$RPROMPT
}

function venv_prompt {
    if [[ -n "$VIRTUAL_ENV" ]];
    then
        echo -n "%{$reset_color%}$(basename $(dirname $VIRTUAL_ENV))"
        echo -n "%{$fg_bold[black]%}/"
        echo -n "%{$fg_bold[blue]%}$(basename $VIRTUAL_ENV)"
        echo -n "%{$fg_bold[black]%} ::"
        echo -n "%{$reset_color%} "
    fi
}
