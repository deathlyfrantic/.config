alias sass='sassc'
alias tmux='tmux -2 -f "$XDG_CONFIG_HOME"/tmux.conf'
alias ls='ls -G'
alias ll='ls -lhG'
alias vim='nvim'
alias less='less -FiXR'
alias irssi='irssi --config="$XDG_CONFIG_HOME"/irssi/config --home="$XDG_CONFIG_HOME"/irssi'
alias xmllint='xmllint --format'
alias sqlite3='sqlite3 -init "$XDG_CONFIG_HOME"/sqliterc'
alias svn='svn --config-dir "$XDG_CONFIG_HOME"/subversion'
alias b='brew'
alias rg='rg -S'
function rgl() { rg -p $* | less } # this is alias-like
alias va='source venv/bin/activate'
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
alias pstree='pstree -g3'
alias mpv='open -na /Applications/mpv.app'
