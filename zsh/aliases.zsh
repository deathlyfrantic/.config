alias sass='sassc'
alias tmux='tmux -2 -f "$XDG_CONFIG_HOME"/tmux/config'
alias ls='ls -G'
alias ll='ls -lhG'
alias vim='nvim'
alias less='less -FiXR'
alias irssi='irssi --config="$XDG_CONFIG_HOME"/irssi/config --home="$XDG_CONFIG_HOME"/irssi'
alias xmllint='xmllint --format'
alias sqlite3='sqlite3 -init "$XDG_CONFIG_HOME"/sqlite3/sqliterc'
alias svn='svn --config-dir "$XDG_CONFIG_HOME"/subversion'
alias b='brew'
alias ltmail='DEFAULT_ACCOUNT=lt mutt'
alias rg='rg -S'
function rgl() { rg -p $* | less } # this is alias-like
# ag colors below, maybe try rg's colors for a while
# alias rg='rg -S --colors line:fg:yellow --colors line:style:bold --colors path:fg:green --colors path:style:bold --colors match:fg:black --colors match:bg:yellow --colors match:style:nobold'
alias va='source venv/bin/activate'
alias hog='du -d1 -h | sort -h'
function mkcd { mkdir -p $1 && cd $1 } # this is alias-like
