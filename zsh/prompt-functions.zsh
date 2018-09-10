function set-up-prompt {
    local user=$(prompt-color-echo %n blue)
    local at=$(prompt-color-echo @ blue bold)
    local host=$(prompt-color-echo %m blue)
    local cwd='%{$fg[white]%}${${(%):-%~}//\//%{$fg_bold[black]%\}/%{$reset_color%\}}'
    local jobs='%(1j.$(prompt-widget jobs %j before).)'

    if [[ -z "$COLORTERM" ]]; then
        local green=$fg_bold[green]
    else
        local green=$(echo -e '\e[38;2;138;226;52m')
    fi

    local base="$cwd$jobs %(!.%{$fg_bold[red]%}#.%{$green%}$)%{$reset_color%} "

    if [[ $SSH_CONNECTION != '' ]]; then
        PROMPT=$user$at$host$(prompt-separator)$base
    elif [[ $USER != 'zandr' ]]; then
        PROMPT=$user$(prompt-separator)$base
    else
        PROMPT=$base
    fi

    RPROMPT='${$(prompt-venv)}${$(prompt-git-status)}$(prompt-timestamp)'
}

function prompt-timestamp {
    local sep=$(prompt-color-echo : black bold)
    local hrs=$(prompt-color-echo %D{%H} reset)
    local min=$(prompt-color-echo %D{%M} reset)
    local sec=$(prompt-color-echo %D{%S} reset)
    echo -n "$hrs$sep$min$sep$sec"
}

function prompt-separator {
    prompt-color-echo " :: " black bold
}

function prompt-venv {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        prompt-widget \
            $(basename $(dirname $VIRTUAL_ENV)) \
            $(basename $VIRTUAL_ENV) \
            after
    fi
}

function prompt-widget {
    local left=$1
    local right=$2
    local sep=$3
    if [[ $sep == "before" ]]; then
        prompt-separator
    fi
    prompt-color-echo $left reset
    prompt-color-echo / black bold
    prompt-color-echo $right blue bold
    if [[ $sep == "after" ]]; then
        prompt-separator
    fi
}

function prompt-color-echo {
    local text=$1
    local color=$2
    local bold=$3
    if [[ $color == "reset" ]]; then
        local esc=$reset_color
    elif [[ $bold != "" ]]; then
        local esc=$fg_bold[$color]
    else
        local esc=$fg[$color]
    fi
    echo -n "%{$esc%}$text%{$reset_color%}"
}

function prompt-git-status {
    local branch=$(git symbolic-ref HEAD 2>&1)
    if [[ $branch =~ "fatal: not a git repository" ]]; then
        return
    fi

    local porcelain=$(git status --porcelain=2 --branch)

    # branch name (and ahead/behind if applicable)
    if [[ $branch =~ "fatal: ref HEAD is not a symbolic ref" ]]; then
        branch=":"$(git rev-parse --short HEAD)
        prompt-color-echo $branch reset
    else
        branch=$(echo $branch | cut -d/ -f3)
        prompt-color-echo $branch reset

        local branchab=$(echo $porcelain | grep branch.ab)
        local ahead=$(echo $branchab | cut -d' ' -f3 | tr -d '+')
        local behind=$(echo $branchab | cut -d' ' -f4 | tr -d '-')

        if [[ $behind > 0 ]]; then
            prompt-color-echo "<$behind" red bold
        fi

        if [[ $ahead > 0 ]]; then
            prompt-color-echo ">$ahead" cyan bold
        fi
    fi

    # separator
    prompt-color-echo / black bold

    local clean=""
    local staged=$(echo $porcelain | grep -c '^[12] [MADRC]\.')
    local conflicts=$(echo $porcelain | grep -c '^u ')
    local changed=$(echo $porcelain | grep -c '^[12] \.[MADRC]')
    local untracked=$(echo $porcelain | grep -c '^? ')

    if [[ $staged > 0 ]]; then
        prompt-color-echo "-$staged" yellow bold
        clean="no"
    fi

    if [[ $conflicts > 0 ]]; then
        prompt-color-echo "!$conflicts" red bold
        clean="no"
    fi

    if [[ $changed > 0 ]]; then
        prompt-color-echo "+$changed" blue bold
        clean="no"
    fi

    if [[ $untracked > 0 ]]; then
        prompt-color-echo "_$untracked" magenta bold
        clean="no"
    fi

    if [[ $clean == "" ]]; then
        prompt-color-echo "=" green bold
    fi

    # separator between widgets
    prompt-separator
}
