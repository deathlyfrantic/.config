cd ~/dotfiles
git clone https://github.com/zsh-users/antigen

cd ~
ln -s ~/dotfiles/antigen/antigen.zsh .antigen.zsh
ln -s ~/dotfiles/tmux.conf .tmux.conf
ln -s ~/dotfiles/Xresources .Xresources
ln -s ~/dotfiles/zshenv .zshenv
ln -s ~/dotfiles/zshrc .zshrc
ln -s ~/dotfiles/gitconfig .gitconfig

mkdir -p ~/.config/nvim
ln -s ~/dotfiles/init.vim ~/.config/nvim/init.vim

mkdir -p ~/.config/fontconfig
ln -s ~/dotfiles/fonts.conf ~/.config/fontconfig/fonts.conf

mkdir -p ~/.mutt
ln -s ~/dotfiles/muttrc ~/.mutt/muttrc

mkdir -p ~/.irssi
ln -s ~/dotfiles/irssi.theme ~/.irssi/irssi.theme
