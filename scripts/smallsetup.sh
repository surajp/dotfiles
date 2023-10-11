apt update
apt install git neovim curl -y >/dev/null
mkdir ~/softwares
mkdir -p ~/.config/nvim
mkdir -p ~/.vim/autoload
# sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
# https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# ln -s /dotfiles/.vimrc ~/.config/nvim/init.vim
# nvim --headless +PlugInstall +qall
