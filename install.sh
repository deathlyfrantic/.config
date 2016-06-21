cd ~/dotfiles
git clone https://github.com/zsh-users/antigen

cd ~
mkdir -p ~/.config/x11
ln -s ~/dotfiles/Xresources ~/.config/x11/xresources
ln -s ~/dotfiles/xinitrc ~/.config/x11/xinitrc

mkdir -p ~/.config/tmux
ln -s ~/dotfiles/tmux.conf ~/.config/tmux/tmux.conf

mkdir -p ~/.config/git
ln -s ~/dotfiles/gitconfig ~/.config/git/config

mkdir -p ~/.config/zsh/antigen
ln -s ~/dotfiles/antigen/antigen.zsh ~/.config/zsh/antigen.zsh
ln -s ~/dotfiles/zshenv ~/.config/zsh/.zshenv
ln -s ~/dotfiles/zshrc ~/.config/zsh/.zshrc

mkdir -p ~/.config/nvim
ln -s ~/dotfiles/init.vim ~/.config/nvim/init.vim

mkdir -p ~/.config/fontconfig
ln -s ~/dotfiles/fonts.conf ~/.config/fontconfig/fonts.conf

mkdir -p ~/.config/sway
ln -s ~/dotfiles/swayconfig ~/.config/sway/config

mkdir -p ~/.config/ranger
ln -s ~/dotfiles/ranger.conf ~/.config/ranger/rc.conf

mkdir -p ~/.config/cmus
ln -s ~/dotfiles/cmusrc ~/.config/cmus/rc

mkdir -p ~/.config/newsbeueter
ln -s ~/dotfiles/newsbeueterurls ~/.config/newsbeuter/urls
ln -s ~/dotfiles/newsbeuterconfig ~/.config/newsbeuter/config

mkdir -p ~/.mutt
ln -s ~/dotfiles/muttrc ~/.config/mutt/muttrc
ln -s ~/dotfiles/mailcap ~/.config/mutt/mailcap


mkdir -p ~/.config/irssi
ln -s ~/dotfiles/irssi.theme ~/.config/irssi/irssi.theme

# remap capslock -> ctrl
sudo ln -s ~/dotfiles/keyboard.hwdb /etc/udev/hwdb.d/90-custom-keyboard.hwdb
sudo udevadm hwdb --update
sudo udevadm trigger
