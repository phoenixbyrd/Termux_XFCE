#!/bin/bash
pkg install zsh git wget -y 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v19.27.0/posh-linux-arm64 -O .oh-my-posh
chmod +x .oh-my-posh
wget https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf 
mv MesloLGMNerdFontPropo-Regular.ttf .termux/font.ttf
termux-reload-settings
wget https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/bubbles.omp.json -O .bubbles.omo.json
echo "eval "$(./.oh-my-posh init zsh --config ~/bubbles.omp.json)""  | tee -a ~/.zshrc > /dev/null
source .zshrc