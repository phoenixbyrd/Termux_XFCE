#!/bin/bash
# Unofficial Bash Strict Mode

set -euo pipefail
IFS=$'\n\t'

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: Gagal Menginstall XFCE di termux."
    echo "Silakan lihat pesan kesalahan di atas"
  fi
}

trap finish EXIT

clear

echo ""
echo "Script Ini Akan Menginstalasi Termux Desktop (XFCE) dan Distro Debian (proot-distro)"
echo ""
read -r -p "Masukan Nama Pengguna Untuk Debian (proot-distro) : " username </dev/tty

termux-change-repo
pkg update -y -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confold"
sed -i '12s/^#//' $HOME/.termux/termux.properties

# Display a message 
clear -x
echo ""
echo "Mengatur akses memori (termux-setup-storage)." 
# Wait for a single character input 
echo ""
read -n 1 -s -r -p "Tekan Apa saja untuk melanjutkan..."
sleep 1
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
wget https://github.com/YuusaaZ/Termux_XFCE/raw/main/start.sh
chmod +x *.sh

./xfce.sh "$username"
./proot.sh "$username"
./utils.sh

# Display a message 
clear -x
echo ""
echo "Menginstall Aplikasi Termux-X11.." 
# Wait for a single character input 
echo ""
read -n 1 -s -r -p "Tekan Apa Saja untuk melanjutkan..."
wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk

source $PREFIX/etc/bash.bashrc
termux-reload-settings

clear -x
echo "Instalasi Termux Desktop (XFCE) Sukses!"
echo "Ketik ./start.sh untuk Memulai Pengalaman Termux Desktop dengan Termux-X11!"
echo "Credits: phoenixbyrd (github)"
echo "Scripts edited by: YuusaaZ (github)"
echo "Follow my ig: @whyzfrsc!"
echo "thank you!"

rm xfce.sh
rm proot.sh
rm utils.sh
rm install.sh