#!/bin/bash

read -p "Install Neovim first? (y/n): " install_nvim

if [ "$install_nvim" = "y" ]; then
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install neovim
fi

sudo apt install make gcc ripgrep unzip git xclip

git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

echo "Done, please run nvim, restart terminal if needed"
