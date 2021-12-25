# key repeat rate
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

# no smart quotes please
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# install brew - check https://brew.sh for up-to-date instructions
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install rust - check rustup.rs for up-to-date instructions
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install brew packages
brew tap homebrew/cask-fonts && brew install font-sf-mono
brew tap homebrew/cask && brew install 1password alacritty firefox netnewswire signal
brew install git neovim ripgrep rustfmt shellcheck stylua tmux tree universal-ctags zola zsh zsh-completions
brew install luarocks && luarocks install luacheck
brew tap damascenorafael/tap && brew install reminders-menubar

# make zsh use .config dir
sudo echo 'export ZDOTDIR=$HOME/.config/zsh' >> /etc/zshenv
ln -s ~/.config/zsh/.zshrc ~/.config/zsh/zshrc
ln -s ~/.config/zsh/.zshenv ~/.config/zsh/zshenv

# link custom firefox css - also requires setting
# `toolkit.legacyUserProfileCustomizations.stylesheets` to true in about:config
ln -s ~/.config/firefox-userChrome.css ~/Library/Application Support/Firefox/Profiles/$profile/chrome/userChrome.css

# set up readline-style key bindings
[ -d ~/Library/KeyBindings ] || mkdir ~/Library/KeyBindings
cp ~/.config/DefaultKeyBinding.dict ~/Library/KeyBindings/

# populate terminfo database for tmux
tic ~/.config/tmux/tmux-256color.terminfo

# link files that don't work with XDG dirs
cd ~
ln -s ~/.config/urlview .urlview
ln -s ~/.config/inputrc .inputrc
cd -
