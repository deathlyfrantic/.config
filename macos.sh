# settings -> keyboard -> modifier keys
#   caps lock -> control
#   option -> command
#   command -> option
#
# settings -> keyboard -> keyboard
#   key repeat to fastest
#   delay until repeat to shortest
#
# settings -> keyboard -> shortcuts
#   mission control -> ⌘M
#   move left a space -> ^⌘[
#   move right a space -> ^⌘]
#   switch to desktop 1 -> ^⌘1
#   switch to desktop 2 -> ^⌘2
#   switch to desktop 3 -> ^⌘3 etc
#   uncheck application windows
#   app shortcuts -> safari -> "New Tab at End" -> ⌘T
#
# settings -> keyboard -> text
#   uncheck correct spelling automatically
#   uncheck capitalize words automatically
#   uncheck add period with double-space
#   uncheck use smart quotes and dashes
#
# settings -> accessibility -> display
#   check reduce motion
#
# settings -> accessibility -> pointer control -> trackpad options
#   check enable dragging, select three finger drag
#
# settings -> desktop & screen saver -> screen saver
#   uncheck show screen saver after
#
# settings -> desktop & screen saver -> hot corners
#   lower right -> put display to sleep
#
# settings -> dock & menu bar
#   check automatically hide and show dock
#   uncheck show recent applications in dock
#
# settings -> sound
#   uncheck play user interface sound effects
#
# settings -> notifications and focus
#   disable sound on all notifications

# install brew - check https://brew.sh for up-to-date instructions
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install rust - check rustup.rs for up-to-date instructions
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# install rust components
rustup component add clippy rustfmt rust-analyzer
# create rustup and cargo completions
mkdir -p "$XDG_CONFIG_HOME/zsh/completions"
rustup completions zsh > "$XDG_CONFIG_HOME/zsh/completions/_rustup"
rustup completions zsh cargo > "$XDG_CONFIG_HOME/zsh/completions/_cargo"

# install brew packages
brew tap homebrew/cask-fonts && brew install font-sf-mono
brew tap homebrew/cask && brew install 1password firefox music-bar netnewswire signal wezterm
brew install git neovim ripgrep selene shellcheck stylua tmux tree universal-ctags
brew install zsh zsh-completions zsh-history-substring-search zsh-syntax-highlighting
brew tap damascenorafael/tap && brew install reminders-menubar

# make zsh use .config dir
sudo echo 'export ZDOTDIR=$HOME/.config/zsh' >> /etc/zshenv
ln -s ~/.config/zsh/.zshrc ~/.config/zsh/zshrc
ln -s ~/.config/zsh/.zshenv ~/.config/zsh/zshenv

# link custom firefox css - also requires setting
# `toolkit.legacyUserProfileCustomizations.stylesheets` to true in about:config
ln -s ~/.config/firefox-userChrome.css ~/Library/Application\ Support/Firefox/Profiles/$profile/chrome/userChrome.css

# set up readline-style key bindings
[ -d ~/Library/KeyBindings ] || mkdir ~/Library/KeyBindings
cp ~/.config/DefaultKeyBinding.dict ~/Library/KeyBindings/

# populate terminfo database for tmux
tic ~/.config/tmux/tmux-256color.terminfo

# install submodules (probably just tmux-thumbs?)
git submodule init
git submodule update

# link files that don't work with XDG dirs
ln -s ~/.config/inputrc ~/.inputrc
