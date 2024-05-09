#!/bin/bash
DIR_TG="$HOME/termux-go"
pkg install zsh git wget -y 
if [ ! -d "$DIR_TG" ]; then
  echo rm -rf $DIR_TG ; mkdir $DIR_TG;
else
mkdir $DIR_TG
fi
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v19.27.0/posh-linux-arm64 -O $DIR_TG/.oh-my-posh
chmod +x $DIR_TG/.oh-my-posh
wget https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf -O $DIR_TG/NerdFont.ttf
mv NerdFont.ttf ~/.termux/font.ttf
termux-reload-settings
#wget https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/bubbles.omp.json -O $DIR_TG.bubbles.omo.json
#echo "eval "$(~/$DIR_TG.oh-my-posh init zsh --config ~/$DIR_TG/bubbles.omp.json)""  | tee -a ~/.zshrc > /dev/null
#source .zshrc