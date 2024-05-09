#!/bin/bash
dir_tg="$HOME/termux-go"
pkg install zsh git wget -y 
if [ ! -d "$DIR_TG" ]; then
  echo rm -rf $dir_tg ; mkdir $dir_tg;
else
mkdir $dir_tg
fi
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v19.27.0/posh-linux-arm64 -O $dir_tg/.oh-my-posh
chmod +x $dir_tg/.oh-my-posh
wget https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf -O $dir_tg/NerdFont.ttf
mv NerdFont.ttf ~/.termux/font.ttf
termux-reload-settings
#wget https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/bubbles.omp.json -O $dir_tg.bubbles.omo.json
#echo "eval "$(~/$dir_tg.oh-my-posh init zsh --config ~/$dir_tg/bubbles.omp.json)""  | tee -a ~/.zshrc > /dev/null
#source .zshrc