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
#   switch to desktop 3 -> ^⌘3 etc - must create spaces first
#   uncheck application windows
#   app shortcuts -> safari -> "New Tab at End" -> ⌘T
#
# settings -> keyboard -> text input -> input sources -> edit
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
# settings -> screen saver
#   start screen saver when inactive -> never
#   turn display off on power adapter when inactive -> 2 hours
#
# settings -> desktop & dock -> hot corners
#   lower right -> put display to sleep
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
# prevent compinit warnings
chmod 755 /opt/homebrew/share

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
