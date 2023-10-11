FROM node:latest
RUN apt update \
&& apt install python3 python3-pip git wget curl tmux exa less jq -y \
&& mkdir ~/softwares \
&& wget https://github.com/neovim/neovim/releases/download/v0.9.4/nvim.appimage -P ~/softwares/ \
&& chmod u+x ~/softwares/nvim.appimage \
&& ~/softwares/nvim.appimage --appimage-extract \
&& mv squashfs-root ~/softwares/nvim \
&& ln -s ~/softwares/nvim/usr/bin/nvim /usr/bin/nvim \
&& npm i -g @salesforce/cli neovim \
&& python3 -m pip install --upgrade pynvim --break-system-packages \
&& mkdir -p ~/.config/nvim \
&& mkdir -p ~/.vim/autoload \
&& mkdir ~/libs \
&& git clone --depth 1 https://github.com/junegunn/fzf.git ~/softwares/fzf \
&& ~/softwares/fzf/install --all \
&& ln -s /dotfiles/.vimrc ~/.config/nvim/init.vim \
&& sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' \
# && ln -s ~/.local/share/nvim/site/autoload/plug.vim ~/.vim/autoload/plug.vim \
&& ln -s /dotfiles/lua ~/.config/nvim/lua \
&& rm ~/softwares/fzf/shell/key-bindings.bash \
&& ln -s /dotfiles/fzf-key-bindings.bash ~/softwares/fzf/shell/key-bindings.bash \
&& ln -s /dotfiles/vimconfig/ftplugin ~/.config/nvim/ftplugin \
&& ln -s /dotfiles/vimconfig/syntax ~/.config/nvim/syntax \
&& ln -s /dotfiles/.bash_aliases ~/.bash_aliases \
&& ln -s /dotfiles/mysnips ~/.vim/mysnips \
&& mkdir -p ~/.vim/plugged/ale/ale_linters/apex \
&& mkdir -p ~/.vim/plugged/ale/autoload/ale \
&& ln -s /dotfiles/apexlsp.vim ~/.vim/plugged/ale/ale_linters/apex/apexlsp.vim \
&& ln -s /dotfiles/pmd.vim ~/.vim/plugged/ale/ale_linters/apex/pmd.vim \
&& ln -s /dotfiles/apex.vim ~/.vim/plugged/ale/autoload/ale/apex.vim \
&& wget https://github.com/forcedotcom/salesforcedx-vscode/raw/develop/packages/salesforcedx-vscode-apex/out/apex-jorje-lsp.jar -P ~/libs \
&& sfdx commands --json > ~/.sfdxcommands.json \
&& sf commands --json > ~/.sfcommands.json
