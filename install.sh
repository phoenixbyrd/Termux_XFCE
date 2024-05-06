#!/bin/bash

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: Failed to setup XFCE on Termux."
    echo "Please refer to the error message(s) above"
  fi
}

trap finish EXIT

clear

echo ""
echo "This script will install XFCE Desktop in Termux along with a Debian proot"
echo ""
read -r -p "Please enter username for proot installation: " username </dev/tty

termux-change-repo
pkg update -y -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confold"
sed -i '12s/^#//' $HOME/.termux/termux.properties

# Display a message 
clear -x
echo ""
echo "Setting up Termux Storage access." 
# Wait for a single character input 
echo ""
read -n 1 -s -r -p "Press any key to continue..."
termux-setup-storage

pkgs=('wget' 'ncurses-utils' 'dbus' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio')

pkg uninstall dbus -y
pkg update
pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

#Create default directories
mkdir -p Desktop
mkdir -p Downloads

#Download required install scripts
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/xfce.sh
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/proot.sh
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/utils.sh
chmod +x *.sh

./xfce.sh "$username"
./proot.sh "$username"
./utils.sh

# Display a message 
clear -x
echo ""
echo "Installing Termux-X11 APK" 
# Wait for a single character input 
echo ""
read -n 1 -s -r -p "Press any key to continue..."
wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk

source $PREFIX/etc/bash.bashrc
termux-reload-settings

clear -x
echo ""
echo ""
echo "Setup completed successfully!"
echo ""
echo "You can now connect to your Termux XFCE4 Desktop to open the desktop use the command start"
echo ""
echo "This will start the termux-x11 server in termux and start the XFCE Desktop and then open the installed Termux-X11 app."
echo ""
echo "To exit, double click the Kill Termux X11 icon on the panel."
echo ""
echo "Enjoy your Termux XFCE4 Desktop experience!"
echo ""
echo ""

rm xfce.sh
rm proot.sh
rm utils.sh
rm install.sh
