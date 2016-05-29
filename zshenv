# fix non-XDG compatible junk
export XDG_CONFIG_HOME=$HOME/.config
export LESSHISTFILE=-
export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
export EDITOR=nvim
export VISUAL=nvim
export ICEAUTHORITY="$XDG_CONFIG_HOME"/x11/iceauthority

# aliases
alias sass='sassc'
alias tmux='tmux -2 -f "$XDG_CONFIG_HOME"/tmux/tmux.conf'
alias ls='ls --color=tty'
alias vim='nvim'
alias less='less -R'
alias mutt='mutt -F "$XDG_CONFIG_HOME"/mutt/muttrc'
alias irssi='irssi --config="$XDG_CONFIG_HOME"/irssi/config --home="$XDG_CONFIG_HOME"/irssi'
alias sway='sway -d 2> "$XDG_CONFIG_HOME"/sway/debug.log'
