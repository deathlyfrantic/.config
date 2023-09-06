alias ls='ls -G'
alias ll='ls -lhG'
alias less='less -FiXR'
alias xmllint='xmllint --format'
alias sqlite3='sqlite3 -init "$XDG_CONFIG_HOME"/sqliterc'
alias b='brew'
alias rg='rg -S'
alias diffstat='diffstat -C'
alias diff='diff --color=auto'
alias mpv='open -na /Applications/mpv.app'
alias hs='history 1 | sed -e "s/^[[:space:]]*[[:digit:]]*[[:space:]]*//" | sort | uniq | star -s'
alias pgrep='pgrep -il'

# alias-like functions
function rgl {
    rg -p "$@" | less
}

function hog {
    if [ -z "$*" ]; then
        du -d1 -h | sort -h
    else
        du -d0 -h "$@" | sort -h
    fi
}

function mkcd {
    mkdir -p "$1" && cd "$1" || exit 1
}

function nvim {
    if [[ -n "$NVIM" && -n "$*" ]]; then
        local args=()
        for arg in "$@"; do
            if [ -f "$arg" ]; then
                args+=("$(pwd -P)/$arg")
            else
                args+=("$arg")
            fi
        done
        command nvim --server "$NVIM" --remote "${args[@]}"
    else
        command nvim "$@"
    fi
}
