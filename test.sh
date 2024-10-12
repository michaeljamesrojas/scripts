read -p "Install Neovim first? (y/n): " answer

if [ "$answer" = "y" ]; then
    sudo apt install neovim
fi