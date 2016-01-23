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
P_base="$P_path %(!.%{$fg_bold[red]%}☠.%{$fg_bold[black]%}⏵)%{$reset_color%} "

if [[ $SSH_CONNECTION != '' ]]; then
    PROMPT=$P_user$P_at$P_host$P_dot$P_base
elif [[ $USER != 'zandr' ]]; then
    PROMPT=$P_user$P_dot$P_base
else
    PROMPT=$P_base
fi

RPROMPT='$(git_super_status)'

# history
HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

# i have no idea what this stuff does! it was in here from the beginning
bindkey -v
zstyle :compinstall filename '/home/zandr/.zshrc'

autoload -Uz compinit
compinit

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

# look at this bullshit just to get home and end keys to work across terminals
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
bindkey "\e[OH" beginning-of-line
bindkey "\e[OF" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[3~" delete-char
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "\e[Z" reverse-menu-complete

# antigen
if [[ ! -a ~/.antigen.zsh ]]; then
    cd ~/dotfiles
    git submodule add git@github.com:zsh-users/antigen.git
    cd ~
    ln -s ~/dotfiles/antigen/antigen.zsh ~/.antigen.zsh
fi

source ~/.antigen.zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle olivierverdier/zsh-git-prompt
antigen apply
