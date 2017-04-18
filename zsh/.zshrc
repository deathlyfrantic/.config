PATH=$HOME/bin:$PATH
REPORTTIME=5

# colors are important here in the future, where we live
autoload colors; colors

# general options
setopt appendhistory autocd extended_history share_history menu_complete prompt_subst
unsetopt beep case_glob flowcontrol

# prompt
P_user="%(!.%{$fg_bold[red]%}!!! %{$reset_color%}.)%{$fg[blue]%}%n%(!.%{$fg_bold[red]%} !!!%{$reset_color%}.)"
P_at="%{$fg_bold[blue]%}@%{$reset_color%}"
P_dot=" %{$fg_bold[black]%}::%{$reset_color%} "
P_host="%{$fg[blue]%}%m"
P_path='%{$fg[white]%}${${(%):-%~}//\//%{$fg_bold[black]%\}/%{$reset_color%\}}'
P_base="$P_path%{$fg_bold[black]%} ::%{$reset_color%} "

if [[ $SSH_CONNECTION != '' ]]; then
    PROMPT=$P_user$P_at$P_host$P_dot$P_base
elif [[ $USER != 'zandr' ]]; then
    PROMPT=$P_user$P_dot$P_base
else
    PROMPT=$P_base
fi
RPROMPT="%{$reset_color%}%D{%H}%{$fg_bold[black]%}:%{$reset_color%}%D{%M}%{$fg_bold[black]%}:%{$reset_color%}%D{%S}"

if [[ -x $(which gitprompt 2> /dev/null) ]]; then
    RPROMPT='${$(gitprompt)} '$RPROMPT
fi

# history
HISTFILE="$ZDOTDIR"/histfile
HISTSIZE=1000000
SAVEHIST=1000000

# i have no idea what this stuff does! it was in here from the beginning
bindkey -v
zstyle :compinstall filename "$ZDOTDIR/.zshrc"

autoload -Uz compinit
compinit

# futuristic zsh commands
autoload zmv
zmodload zsh/datetime

# completion stuff stolen from github.com/eevee/rc/.zshrc
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=**' 'r:|=**'
zstyle ':completion:*' menu select yes
zstyle ':completion:*:default' list-colors ''
zstyle ':completion:*' max-errors 2

# Turn on caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/"

# Show titles for completion types and group by type
zstyle ':completion:*:descriptions' format "$fg_bold[black]:: $fg_bold[blue]%d$reset_color"
zstyle ':completion:*' group-name ''

# Ignore some common useless files
zstyle ':completion:*' ignored-patterns '*?.pyc' '__pycache__'
zstyle ':completion:*:*:rm:*:*' ignored-patterns

# hopefully a much saner keyboard mapping section
autoload zkbd
if [[ -a $ZDOTDIR/zkbd/$TERM ]]; then
    source $ZDOTDIR/zkbd/$TERM
    [[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
    [[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
    [[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
    [[ -n ${key[Up]} ]] && bindkey "${key[Up]}" history-substring-search-up
    [[ -n ${key[Down]} ]] && bindkey "${key[Down]}" history-substring-search-down
fi
bindkey '^[[Z' reverse-menu-complete
bindkey '^J' history-substring-search-down
bindkey '^K' history-substring-search-up

if [[ -a /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
    source /usr/share/doc/pkgfile/command-not-found.zsh
fi

# antigen
ADOTDIR=$ZDOTDIR/antigen
if [[ -a $ADOTDIR/antigen.zsh ]]; then
    source $ADOTDIR/antigen.zsh
    # redirects below so syntax highlighting doesn't whine about substring widgets being unhandled
    antigen bundle zsh-users/zsh-syntax-highlighting 2> /dev/null
    antigen bundle zsh-users/zsh-history-substring-search
    antigen apply
else
    mkdir -p $ADOTDIR
    git clone https://github.com/zsh-users/antigen $ADOTDIR
fi
