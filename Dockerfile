FROM node:latest
RUN apt update \
&& apt install python3 python3-pip git wget curl tmux exa -y \
&& mkdir ~/softwares \
&& wget https://github.com/neovim/neovim/releases/download/v0.8.3/nvim.appimage -P ~/softwares/ \
&& chmod u+x ~/softwares/nvim.appimage \
&& ~/softwares/nvim.appimage --appimage-extract \
&& mv squashfs-root ~/softwares/nvim \
&& ln -s ~/softwares/nvim/usr/bin/nvim /usr/bin/nvim \
&& npm i -g sfdx-cli neovim \
&& pip install pynvim \
&& pip3 install pynvim \
&& mkdir -p ~/.config/nvim \
&& mkdir -p ~/.vim/autoload \
&& mkdir ~/libs \
&& git clone --depth 1 https://github.com/junegunn/fzf.git ~/softwares/fzf \
&& ~/softwares/fzf/install --all \
&& sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' \
&& ln -s ~/.local/share/nvim/site/autoload/plug.vim ~/.vim/autoload/plug.vim \
&& wget https://github.com/forcedotcom/salesforcedx-vscode/raw/develop/packages/salesforcedx-vscode-apex/out/apex-jorje-lsp.jar -P ~/libs
