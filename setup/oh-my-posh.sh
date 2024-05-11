#!/bin/bash
# Function to remove a file if it exists
function remove_if_exists() {
    file="$1"
    if [ -f "$file" ]; then
        rm -f "$file"
        echo "file already exists. Removing..."
    fi
}
dirtg=$HOME/.termux-go # Make repo dir
temp_dir=$(mktemp -d)  # temp dir
pkg install git wget zsh -y
# Check if the directory exists
if [ -d "$dirtg" ]; then
    echo "Directory already exists. Deleting..."
    rm -rf "$dirtg"
    echo "Directory deleted."
else
    mkdir -p "$dirtg"
fi
remove_if_exists "/data/data/com.termux/files/usr/bin/oh-my-posh"
wget --output-document="$temp_dir/oh-my-posh" "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v19.27.0/posh-linux-arm64"
mv "$temp_dir"/oh-my-posh /data/data/com.termux/files/usr/bin/oh-my-posh
remove_if_exists "~/.termux/font.ttf"
wget https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf -O $dirtg/NerdFont.ttf
mv $HOME/.termux-go/NerdFont.ttf ~/.termux/font.ttf
termux-reload-settings
wget --output-document="$temp_dir/bubbles.omp.json" "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/bubbles.omp.json"
mv "$temp_dir"/bubbles.omp.json /data/data/com.termux/files/usr/bin/bubbles.omp.json
eval "$(/data/data/com.termux/files/usr/bin/oh-my-posh init zsh --config /data/data/com.termux/files/usr/bin/bubbles.omp.json)"
