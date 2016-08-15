# colors are important here in the future, where we live
autoload colors; colors

# general options
setopt appendhistory autocd extended_history share_history menu_complete prompt_subst
unsetopt beep

# prompt
P_user="%{$fg[blue]%}%n"
P_at="%{$fg_bold[blue]%}@%{$reset_color%}"
P_dot=" %{$fg_bold[black]%}·%{$reset_color%} "
P_host="%{$fg[blue]%}%m"
P_path='%{$fg[white]%}${${(%):-%~}//\//%{$fg_bold[black]%\}/%{$reset_color%\}}'
P_base="$P_path%(!.%{$fg_bold[red]%}☠.%{$fg_bold[black]%}:)%{$reset_color%} "

if [[ $SSH_CONNECTION != '' ]]; then
    PROMPT=$P_user$P_at$P_host$P_dot$P_base
elif [[ $USER != 'zandr' ]]; then
    PROMPT=$P_user$P_dot$P_base
else
    PROMPT=$P_base
fi

# history
HISTFILE="$ZDOTDIR"/histfile
HISTSIZE=1000000
SAVEHIST=1000000

# i have no idea what this stuff does! it was in here from the beginning
bindkey -v
zstyle :compinstall filename '/home/zandr/.zshrc'

autoload -Uz compinit
compinit

# futuristic zsh commands
autoload zmv

# completion stuff stolen from github.com/eevee/rc/.zshrc
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=**' 'r:|=**'
zstyle ':completion:*' menu select yes
zstyle ':completion:*:default' list-colors ''
zstyle ':completion:*' max-errors 2

# Turn on caching, which helps with e.g. apt
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Show titles for completion types and group by type
zstyle ':completion:*:descriptions' format "$fg_bold[black]» %d$reset_color"
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
bindkey '^J' history-substring-search-down
bindkey '^K' history-substring-search-up

if [[ -a /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
    source /usr/share/doc/pkgfile/command-not-found.zsh
fi

# antigen
ADOTDIR=$ZDOTDIR/antigen
if [[ -a $ZDOTDIR/antigen.zsh ]]; then
    source $ZDOTDIR/antigen.zsh
    antigen bundle zsh-users/zsh-history-substring-search
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle olivierverdier/zsh-git-prompt
    antigen apply
    RPROMPT='$(git_super_status)'
fi

# git prompt chars
ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[black]%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[yellow]%}%{-%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg_bold[red]%}%{!%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg_bold[blue]%}%{+%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[red]%}%{<%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[cyan]%}%{>%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[magenta]%}%{?%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{=%G%}"
