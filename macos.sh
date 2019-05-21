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

# disable google analytics on porting kit
defaults write ~/Library/Preferences/edu.ufrj.vitormm.Porting-Kit.plist "Disable Google Analytics API" -bool true

# install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# base brew packages i need
brew install git
brew install mutt urlview w3m
brew install neovim
brew install ripgrep
brew install tmux
brew install zsh zsh-completions
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
brew install tree
brew cask install alacritty
brew cask install firefox
brew cask install iterm2
brew cask install signal

# install rust
curl https://sh.rustup.rs -sSf | sh

# make zsh use .config dir
sudo echo 'export ZDOTDIR=$HOME/.config/zsh' >> /etc/zshenv

# link custom firefox css
ln -s ~/.config/firefox-userChrome.css ~/Library/Application Support/Firefox/Profile/$profile/chrome/userChrome.css

# set up readline-style key bindings
[ -d ~/Library/KeyBindings ] || mkdir ~/Library/KeyBindings
cp ~/.config/DefaultKeyBinding.dict ~/Library/KeyBindings/

# populate terminfo database for tmux
tic ~/.config/tmux/tmux-256color.terminfo
