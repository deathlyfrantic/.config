# key repeat rate
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

# no smart quotes please
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# dashboard off
defaults write com.apple.dashboard mcx-disabled -boolean true
