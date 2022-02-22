alias sass='sassc'
alias tmux='tmux -f "$XDG_CONFIG_HOME"/tmux/config'
alias ls='ls -G'
alias ll='ls -lhG'
alias vim='nvim'
alias less='less -FiXR'
alias xmllint='xmllint --format'
alias sqlite3='sqlite3 -init "$XDG_CONFIG_HOME"/sqliterc'
alias b='brew'
alias rg='rg -S'
function rgl() { rg -p $* | less } # this is alias-like
function hog {
    if [ -z "$*" ]; then
        du -d1 -h | sort -h
    else
        du -d0 -h $* | sort -h
    fi
}
function mkcd { mkdir -p $1 && cd $1 } # this is alias-like
alias diffstat='diffstat -C'
alias diff='diff --color=auto'
alias mpv='open -na /Applications/mpv.app'
alias hs='history 1 | sed -e "s/^[[:space:]]*[[:digit:]]*[[:space:]]*//" | star -s'
alias redo='eval `hs`'
alias pgrep='pgrep -i'
