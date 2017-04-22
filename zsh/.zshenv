# fix non-XDG compatible junk
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
export INPUTRC="$XDG_CONFIG_HOME"/inputrc
export ICEAUTHORITY="$XDG_CONFIG_HOME"/x11/iceauthority
export XAUTHORITY="$XDG_CONFIG_HOME"/x11/xauthority
export XINITRC="$XDG_CONFIG_HOME"/x11/xinitrc
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node/history
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/startup.py
export LESSHISTFILE=-
export EDITOR=nvim
export VISUAL=nvim
export WLC_REPEAT_DELAY=500
export WLC_REPEAT_RATE=30
export GDK_BACKEND=x11

# aliases
alias gpg2='gpg2 --homedir "$XDG_CONFIG_HOME/gnupg"'
alias sass='sassc'
alias tmux='tmux -2 -f "$XDG_CONFIG_HOME"/tmux/config'
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias vim='nvim'
alias less='less -R'
alias pacman='pacman --color=always'
alias irssi='irssi --config="$XDG_CONFIG_HOME"/irssi/config --home="$XDG_CONFIG_HOME"/irssi'
alias sway='sway -d 2> "$XDG_CACHE_HOME"/sway-debug.log'
alias startx='startx "$XDG_CONFIG_HOME"/x11/xinitrc'
alias xmllint='xmllint --format'
alias hog='du --max-depth=1 | sort -n'
alias nb='newsbeuter'
alias todo='todo.sh -d "$XDG_CONFIG_HOME"/todo.cfg'

# functions
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
