#!/bin/bash

username="$1"

pkgs=('git' 'neofetch' 'virglrenderer-android' 'papirus-icon-theme' 'xfce4' 'xfce4-goodies' 'eza' 'pavucontrol-qt' 'bat' 'jq' 'nala' 'wmctrl' 'firefox' 'netcat-openbsd' 'termux-x11-nightly' 'eza')

#Install xfce4 desktop and additional packages
pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

#Put Firefox icon on Desktop
cp $PREFIX/share/applications/firefox.desktop $HOME/Desktop 
chmod +x $HOME/Desktop/firefox.desktop

#Set aliases
echo "
alias debian='proot-distro login debian --user $username --shared-tmp'
#alias zrun='proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform '
#alias zrunhud='proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform GALLIUM_HUD=fps '
alias hud='GALLIUM_HUD=fps '
alias ls='eza -lF --icons'
alias cat='bat '
alias apt='nala '
alias install='nala install -y '
alias uninstall='nala remove -y '
alias search='nala search '
alias list='nala list --upgradeable'
alias show='nala show'
" >> $PREFIX/etc/bash.bashrc
