#!/bin/bash
<<<<<<<<<<<<<<  ✨ Codeium Command 🌟 >>>>>>>>>>>>>>>>
+echo "Running setup/oh-my-posh.sh"
+echo "dirtg=$HOME/termux-go"
dirtg="$HOME/termux-go"
<<<<<<<  e5e861cb-d3dc-42dc-8dc7-1130dc61a77b  >>>>>>>
pkg install zsh git wget -y 
if [ ! -d "$dirtg" ]; then
  echo rm -rf $dirtg ; mkdir $dirtg;
else
mkdir $dirtg
fi
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v19.27.0/posh-linux-arm64 -O $dirtg/.oh-my-posh
chmod +x $dirtg/.oh-my-posh
wget https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf -O $dirtg/NerdFont.ttf
mv NerdFont.ttf ~/.termux/font.ttf
termux-reload-settings
#wget https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/bubbles.omp.json -O $dirtg.bubbles.omo.json
#echo "eval "$(~/$dirtg.oh-my-posh init zsh --config ~/$dirtg/bubbles.omp.json)""  | tee -a ~/.zshrc > /dev/null
#source .zshrc