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
