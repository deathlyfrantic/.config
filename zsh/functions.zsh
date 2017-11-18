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

    if [[ $TERM == 'linux' || $TERM == 'xterm' ]];
    then
        local _green=$fg_bold[green]
    else
        local _green=$(echo -e '\e[38;2;138;226;52m')
    fi

    local _base="$_path %(!.%{$fg_bold[red]%}#.%{$_green%}$)%{$reset_color%} "

    if [[ $SSH_CONNECTION != '' ]];
    then
        PROMPT=$_user$_at$_host$_dot$_base
    elif [[ $USER != 'zandr' ]];
    then
        PROMPT=$_user$_dot$_base
    else
        PROMPT=$_base
    fi

    RPROMPT="%{$reset_color%}%D{%H}%{$fg_bold[black]%}:%{$reset_color%}%D{%M}%{$fg_bold[black]%}:%{$reset_color%}%D{%S}"

    if [[ -x $(which gitprompt 2> /dev/null) ]];
    then
        RPROMPT='${$(gitprompt)}'$RPROMPT
    else
        RPROMPT='${$(git_prompt)}'$RPROMPT
    fi

    RPROMPT='${$(venv_prompt)}'$RPROMPT
}

function venv_prompt {
    if [[ -n "$VIRTUAL_ENV" ]];
    then
        prompt_color_echo $(basename $(dirname $VIRTUAL_ENV)) reset
        prompt_color_echo / black bold
        prompt_color_echo $(basename $VIRTUAL_ENV) blue bold
        prompt_color_echo " :: " black bold
    fi
}

function prompt_color_echo {
    local text=$1
    local color=$2
    local bold=$3

    if [[ $color == "reset" ]];
    then
        local esc=$reset_color
    elif [[ $bold != "" ]];
    then
        local esc=$fg_bold[$color]
    else
        local esc=$fg[$color]
    fi

    echo -n "%{$esc%}$text%{$reset_color%}"
}

function git_prompt {
    local branch=$(git symbolic-ref HEAD 2>&1)
    if [[ $branch =~ "fatal: Not a git repository" ]];
    then
        return
    fi

    # branch name (and ahead/behind if applicable)
    if [[ $branch =~ "fatal: ref HEAD is not a symbolic ref" ]];
    then
        branch=":"$(git rev-parse --short HEAD)
        prompt_color_echo $branch reset
    else
        branch=$(echo $branch | cut -d/ -f3)
        prompt_color_echo $branch reset

        local ab=$_git_prompt_ahead_behind
        local behind=$(echo $ab | cut -f1 -d' ')
        local ahead=$(echo $ab | cut -f2 -d' ')

        if [[ $behind > 0 ]];
        then
            prompt_color_echo "<$behind" red bold
        fi

        if [[ $ahead > 0 ]];
        then
            prompt_color_echo ">$ahead" cyan bold
        fi
    fi

    # separator
    prompt_color_echo / black bold

    local clean=""

    # staged
    local staged=$(git diff --staged --name-status | wc -l | tr -d '[:blank:]')
    if [[ $staged > 0 ]];
    then
        prompt_color_echo "-$staged" yellow bold
        clean="no"
    fi

    # conflicts
    local conflicts=$(git diff --staged --name-status | grep -c '^U ' | tr -d '[:blank:]')
    if [[ $conflicts > 0 ]];
    then
        prompt_color_echo "!$conflicts" red bold
        clean="no"
    fi

    # changed
    local changed=$(git diff --name-status | wc -l | tr -d '[:blank:]')
    if [[ $changed > 0 ]];
    then
        prompt_color_echo "+$changed" blue bold
        clean="no"
    fi

    # untracked
    local untracked=$(git status --porcelain | grep -c '^?? ' | tr -d '[:blank:]')
    if [[ $untracked > 0 ]];
    then
        prompt_color_echo "_$untracked" magenta bold
        clean="no"
    fi

    # clean
    if [[ $clean == "" ]];
    then
        prompt_color_echo "=" green bold
    fi

    # separator between widgets
    prompt_color_echo " :: " black bold
}

function _git_prompt_ahead_behind {
    local branch=$1
    local remote=$(git config branch.$branch.remote)

    if [[ $remote == "" ]];
    then
        return
    fi

    local merge=$(git config branch.$branch.merge)

    if [[ $remote == "." ]];
    then
        local ref=$merge
    else
        local ref="refs/remotes/$remote/$(echo $merge | cut -d/ -f3)"
    fi

    local revs=$(git rev-list --left-right $ref...HEAD)
    local behind=$(echo $revs | grep -c '^>')
    local ahead=$(echo $revs | grep -c '^<')
    echo $behind $ahead
}

function zshaddhistory {
    # don't save boring history
    if [[ $1 =~ '^ls' ]]; then
        return 1
    fi
    if [[ $1 =~ '^antigen update' ]]; then
        return 1
    fi
    if [[ $1 =~ '^b upgrade' || $1 =~ 'brew upgrade' ]]; then
        return 1
    fi
    return 0
}

function hog {
    local -a contents=("${(@f)$(du -d1 | sort -n | cut -f2)}")

    for i in $contents;
    do
        du -d0 -h $i
    done
}

function timer {
    if [[ $1 == "" ]]; then
        local secs=60
    else
        local secs=$1
    fi
    repeat $secs echo -n "." && sleep 1
    echo "\n\n### TIMER DONE ###\n"
}
