# key repeat rate
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

# no smart quotes please
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# dashboard off
defaults write com.apple.dashboard mcx-disabled -boolean true

# time machine does not need to run every hour, that is ridiculous
# does this work? idk
sudo defaults write com.apple.backupd-auto Interval -int 43200

# make signal title bar dark
defaults write org.whispersystems.signal-desktop NSRequiresAquaSystemAppearance -bool false

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install brew packages
brew bundle

# install rust
curl https://sh.rustup.rs -sSf | sh

# make zsh use .config dir
sudo echo 'export ZDOTDIR=$HOME/.config/zsh' >> /etc/zshenv
ln -s ~/.config/zsh/.zshrc ~/.config/zsh/zshrc
ln -s ~/.config/zsh/.zshenv ~/.config/zsh/zshenv

# link custom firefox css
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
ln -s ~/.config/bin .
cd -
