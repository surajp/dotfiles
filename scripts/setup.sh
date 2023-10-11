#!/usr/bin/env bash

apt update
apt install neovim python3-pip python3 git wget curl tmux -y
npm i -g sfdx-cli neovim
pip install pynvim
pip3 install pynvim
mkdir -p ~/.config/nvim
mkdir -p ~/.vim/autoload
mkdir ~/libs
mkdir ~/softwares
git clone --depth 1 https://github.com/junegunn/fzf.git ~/softwares/fzf
~/softwares/fzf/install --all
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
ln -s /dotfiles/.vimrc ~/.config/nvim/init.vim
nvim --headless +PlugInstall +qall
rm ~/softwares/fzf/shell/key-bindings.bash
ln -s /dotfiles/fzf-key-bindings.bash ~/softwares/fzf/shell/key-bindings.bash
ln -s /dotfiles/vimconfig/ftplugin ~/.config/nvim/ftplugin
ln -s /dotfiles/vimconfig/syntax ~/.config/nvim/syntax
ln -s /dotfiles/.bash_aliases ~/.bash_aliases
ln -s /dotfiles/mysnips ~/.vim/mysnips
ln -s /dotfiles/apexlsp.vim ~/.vim/plugged/ale/ale_linters/apex/apexlsp.vim
ln -s /dotfiles/pmd.vim ~/.vim/plugged/ale/ale_linters/apex/pmd.vim
ln -s /dotfiles/apex.vim ~/.vim/plugged/ale/autoload/ale/apex.vim
wget https://github.com/forcedotcom/salesforcedx-vscode/raw/develop/packages/salesforcedx-vscode-apex/out/apex-jorje-lsp.jar -P ~/libs
