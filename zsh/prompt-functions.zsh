function set-up-prompt {
    local user at host
    user=$(prompt-color-echo %n blue)
    at=$(prompt-color-echo @ blue bright)
    host=$(prompt-color-echo %m blue)
    # shellcheck disable=SC2016
    local cwd='${${(%):-%~}//\//%{$fg_bright[black]%\}/%{$reset_color%\}}'
    # shellcheck disable=SC2016
    local jobs='%(1j.$(prompt-widget jobs %j before).)'
    # shellcheck disable=SC2016
    local code='%(0?..$(prompt-widget exit %? before))'
    # shellcheck disable=SC2016
    local char=' %(!.%{$fg_bright[red]%}#.%{$fg_bright[green]%}$)'
    local base="$cwd$jobs$code$char%{$reset_color%} "

    if [[ $SSH_TTY != "" ]]; then
        PROMPT=$user$at$host$(prompt-separator)$base
    elif [[ $USER != "zandr" ]]; then
        PROMPT=$user$(prompt-separator)$base
    else
        PROMPT=$base
    fi
    export PROMPT

    # shellcheck disable=SC2016
    RPROMPT='${$(prompt-venv)}${$(prompt-git-status)}$(prompt-timestamp)'
    export RPROMPT
}

function prompt-timestamp {
    local sep hrs min sec
    sep=$(prompt-color-echo : black bright)
    hrs=$(prompt-color-echo "%D{%H}" reset)
    min=$(prompt-color-echo "%D{%M}" reset)
    sec=$(prompt-color-echo "%D{%S}" reset)
    echo -n "$hrs$sep$min$sep$sec"
}

function prompt-separator {
    prompt-color-echo " :: " black bright
}

function prompt-venv {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        prompt-widget \
            "$(basename "$(dirname "$VIRTUAL_ENV")")" \
            "$(basename "$VIRTUAL_ENV")" \
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
    prompt-color-echo "$left" reset
    prompt-color-echo / black bright
    prompt-color-echo "$right" blue bright
    if [[ $sep == "after" ]]; then
        prompt-separator
    fi
}

function prompt-color-echo {
    local text=$1
    local color=$2
    local modifier=$3
    if [[ $color == "reset" ]]; then
        local esc=$reset_color
    elif [[ $modifier == "bright" ]]; then
        local esc=${fg_bright[$color]}
    elif [[ $modifier == "bold" ]]; then
        local esc=${fg_bold[$color]}
    else
        local esc=${fg[$color]}
    fi
    echo -n "%{$esc%}$text%{$reset_color%}"
}

function prompt-git-status {
    local porcelain
    porcelain=$(git status --porcelain=2 --branch 2>&1)
    if [[ $porcelain =~ "fatal:" ]]; then
        return
    fi

    # branch name (and ahead/behind if applicable)
    local branch
    branch=$(echo "$porcelain" | awk '$2 == "branch.head" { print $3 }')
    if [[ $branch == "(detached)" ]]; then
        branch=":"$(git rev-parse --short HEAD)
        prompt-color-echo "$branch" reset
    else
        prompt-color-echo "$branch" reset
        local branchab
        branchab=$(echo "$porcelain" | grep branch.ab)
        if [[ $branchab != "" ]]; then
            local ahead behind
            ahead=$(echo "$branchab" | awk '{ print $3 + 0 }')
            behind=$(echo "$branchab" | awk '{ print $4 + 0 }')
            prompt-git-status-echo-if-nonzero "$behind" "<" red bright
            prompt-git-status-echo-if-nonzero "$ahead" ">" cyan bright
        fi
    fi

    # separator
    prompt-color-echo / black bright

    # staged/conflicts/changed/untracked
    local staged conflicts changed untracked
    staged=$(echo "$porcelain" | grep -c '^[12] [MADRC].')
    conflicts=$(echo "$porcelain" | grep -c '^u ')
    changed=$(echo "$porcelain" | grep -c '^[12] .[MADRC]')
    untracked=$(echo "$porcelain" | grep -c '^? ')
    prompt-git-status-echo-if-nonzero "$staged" "-" yellow bright
    prompt-git-status-echo-if-nonzero "$conflicts" "!" red bright
    prompt-git-status-echo-if-nonzero "$changed" "+" blue bright
    prompt-git-status-echo-if-nonzero "$untracked" "_" magenta bright

    # clean
    if [[ $((staged + conflicts + changed + untracked)) -eq 0 ]]; then
        prompt-color-echo "=" green bright
    fi

    # separator between widgets
    prompt-separator
}

function prompt-git-status-echo-if-nonzero {
    local number=$1
    local symbol=$2
    local color=$3
    local modifier=$4

    if [[ "$number" -gt 0 ]]; then
        prompt-color-echo "$symbol$number" "$color" "$modifier"
    fi
}
