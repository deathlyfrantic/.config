# fix non-XDG compatible junk
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
export ICEAUTHORITY="$XDG_CONFIG_HOME"/x11/iceauthority
export XAUTHORITY="$XDG_CONFIG_HOME"/x11/xauthority
export XINITRC="$XDG_CONFIG_HOME"/x11/xinitrc
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node/history
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/startup.py
export LESSHISTFILE=-
export EDITOR=nvim
export VISUAL=nvim
export GDK_BACKEND=x11

# aliases
alias gpg2='gpg2 --homedir "$XDG_CONFIG_HOME/gnupg"'
alias sass='sassc'
alias tmux='tmux -2 -f "$XDG_CONFIG_HOME"/tmux/config'
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias vim='nvim'
alias less='less -R'
alias mutt='mutt -F "$XDG_CONFIG_HOME"/mutt/muttrc'
alias ltmail='"$XDG_CONFIG_HOME"/mutt/ltmail.zsh'
alias pacman='pacman --color=always'
alias irssi='irssi --config="$XDG_CONFIG_HOME"/irssi/config --home="$XDG_CONFIG_HOME"/irssi'
alias sway='sway -d 2> "$XDG_CONFIG_HOME"/sway/debug.log'
alias startx='startx "$XDG_CONFIG_HOME"/x11/xinitrc'
alias xmllint='xmllint --format'

escape_for_pango () {
    echo "$1" \
        | sed -e 's/&/\&amp\;amp\;/g' \
        | sed -e 's/>/\&gt\;/g' \
        | sed -e 's/</\&lt\;/g' \
        | sed -e "s/'/\&apos\;/g" \
        | sed -e 's/"/\&quot\;/g'
}
