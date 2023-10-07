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

termux-setup-storage
termux-change-repo

pkg update -y -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confold"
pkg uninstall dbus -y
pkg install wget ncurses-utils dbus proot-distro x11-repo tur-repo pulseaudio -y

#Create default directories
mkdir -p Desktop
mkdir -p Downloads

setup_proot() {
#Install Debian proot
proot-distro install debian
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 apt update
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 apt upgrade -y
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 apt install sudo wget nala jq flameshot conky-all -y

#Create user
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 groupadd storage
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 groupadd wheel
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"

#Add user to sudoers
chmod u+rw $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w  $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

#Set proot DISPLAY
echo "export DISPLAY=:1.0" >> $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

#Set proot aliases
echo "
alias virgl='GALLIUM_DRIVER=virpipe '
alias ls='exa -lF --icons'
alias cat='bat '
alias apt='sudo nala '
alias start='echo "please run from termux, not debian proot."'
" >> $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

#Set proot timezone
timezone=$(getprop persist.sys.timezone)
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime
}

setup_xfce() {
#Install xfce4 desktop and additional packages
pkg install git neofetch virglrenderer-android papirus-icon-theme xfce4 xfce4-goodies pavucontrol-qt exa bat jq nala wmctrl firefox netcat-openbsd -y

#Create .bashrc
cp $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/etc/skel/.bashrc $HOME/.bashrc

#Enable Sound
echo "
pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
" > $HOME/.sound

echo "
source .sound" >> .bashrc

#Set aliases
echo "
alias debian='proot-distro login debian --user $username --shared-tmp'
alias ls='exa -lF --icons'
alias cat='bat '
alias apt='pkg upgrade -y && nala $@'
" >> $HOME/.bashrc

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/ascii-image-converter
mv ascii-image-converter $HOME/../usr/bin
chmod +x $HOME/../usr/bin/ascii-image-converter

#Put Firefox icon on Desktop
cp $HOME/../usr/share/applications/firefox.desktop $HOME/Desktop 
chmod +x $HOME/Desktop/firefox.desktop

cat <<'EOF' > ../usr/bin/prun
#!/bin/bash
varname=$(basename $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/*)
proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 $@

EOF
chmod +x ../usr/bin/prun

cat <<'EOF' > ../usr/bin/cp2menu
#!/bin/bash

cd

user_dir="../usr/var/lib/proot-distro/installed-rootfs/debian/home/"

# Get the username from the user directory
username=$(basename "$user_dir"/*)

action=$(zenity --list --title="Choose Action" --text="Select an action:" --radiolist --column="" --column="Action" TRUE "Copy .desktop file" FALSE "Remove .desktop file")

if [[ -z $action ]]; then
  zenity --info --text="No action selected. Quitting..." --title="Operation Cancelled"
  exit 0
fi

if [[ $action == "Copy .desktop file" ]]; then
  selected_file=$(zenity --file-selection --title="Select .desktop File" --file-filter="*.desktop" --filename="../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications")

  if [[ -z $selected_file ]]; then
    zenity --info --text="No file selected. Quitting..." --title="Operation Cancelled"
    exit 0
  fi

  desktop_filename=$(basename "$selected_file")

  cp "$selected_file" "../usr/share/applications/"
  sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 \1/" "../usr/share/applications/$desktop_filename"

  zenity --info --text="Operation completed successfully!" --title="Success"
elif [[ $action == "Remove .desktop file" ]]; then
  selected_file=$(zenity --file-selection --title="Select .desktop File to Remove" --file-filter="*.desktop" --filename="../usr/share/applications")

  if [[ -z $selected_file ]]; then
    zenity --info --text="No file selected for removal. Quitting..." --title="Operation Cancelled"
    exit 0
  fi

  desktop_filename=$(basename "$selected_file")

  rm "$selected_file"

  zenity --info --text="File '$desktop_filename' has been removed successfully!" --title="Success"
fi

EOF
chmod +x ../usr/bin/cp2menu

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=cp2menu
Comment=
Exec=cp2menu
Icon=edit-move
Categories=System;
Path=
Terminal=false
StartupNotify=false
" > $HOME/Desktop/cp2menu.desktop 
chmod +x $HOME/Desktop/cp2menu.desktop
mv $HOME/Desktop/cp2menu.desktop $HOME/../usr/share/applications

#App Installer Utility
git clone https://github.com/phoenixbyrd/App-Installer.git
mv $HOME/App-Installer $HOME/.App-Installer
chmod +x $HOME/.App-Installer/*

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=App Installer
Comment=
Exec=/data/data/com.termux/files/home/.App-Installer/app-installer
Icon=package-install
Categories=System;
Path=
Terminal=false
StartupNotify=false
" > $HOME/Desktop/App-Installer.desktop
chmod +x $HOME/Desktop/App-Installer.desktop
cp $HOME/Desktop/App-Installer.desktop $HOME/../usr/share/applications

}

setup_termux_x11() {
# Install Termux-X11
sed -i '12s/^#//' $HOME/.termux/termux.properties

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/termux-x11.deb
dpkg -i termux-x11.deb
rm termux-x11.deb
apt-mark hold termux-x11-nightly

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/termux-x11.apk
mv termux-x11.apk $HOME/storage/downloads/
termux-open $HOME/storage/downloads/termux-x11.apk

#Create kill_termux_x11.desktop
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Kill Termux X11
Comment=
Exec=kill_termux_x11
Icon=system-shutdown
Categories=System;
Path=
StartupNotify=false
" > $HOME/Desktop/kill_termux_x11.desktop
chmod +x $HOME/Desktop/kill_termux_x11.desktop
mv $HOME/Desktop/kill_termux_x11.desktop $HOME/../usr/share/applications

#Create XFCE Start and Shutdown
cat <<'EOF' > start
#!/bin/bash

MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 virgl_test_server_android --angle-gl & > /dev/null 2>&1
sleep 1
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1.0 &
sleep 1
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1
env DISPLAY=:1.0 GALLIUM_DRIVER=virpipe dbus-launch --exit-with-session xfce4-session & > /dev/null 2>&1

sleep 5
process_id=$(ps -aux | grep '[x]fce4-screensaver' | awk '{print $2}')
kill "$process_id" > /dev/null 2>&1

EOF

chmod +x start
mv start $HOME/../usr/bin

#Shutdown Utility
cat <<'EOF' > $HOME/../usr/bin/kill_termux_x11
#!/bin/bash

# Check if Apt, dpkg, or Nala is running in Termux or Proot
if pgrep -f 'apt|apt-get|dpkg|nala'; then
  zenity --info --text="Software is currently installing in Termux or Proot. Please wait for this processes to finish before continuing."
  exit 1
fi

# Get the process IDs of Termux-X11 and XFCE sessions
termux_x11_pid=$(pgrep -f "/system/bin/app_process / com.termux.x11.Loader :1.0")
xfce_pid=$(pgrep -f "xfce4-session")

# Check if the process IDs exist
if [ -n "$termux_x11_pid" ] && [ -n "$xfce_pid" ]; then
  # Kill the processes
  kill -9 "$termux_x11_pid" "$xfce_pid"
  zenity --info --text="Termux-X11 and XFCE sessions closed."
else
  zenity --info --text="Termux-X11 or XFCE session not found."
fi

info_output=$(termux-info)
pid=$(echo "$info_output" | grep -o 'TERMUX_APP_PID=[0-9]\+' | awk -F= '{print $2}')
kill "$pid"

exit 0

EOF

chmod +x $HOME/../usr/bin/kill_termux_x11
}

setup_theme() {
#Download Wallpaper
wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/peakpx.jpg
wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/dark_waves.png
mv peakpx.jpg $HOME/../usr/share/backgrounds/xfce/
mv dark_waves.png $HOME/../usr/share/backgrounds/xfce/

#Install WhiteSur-Dark Theme
wget https://github.com/vinceliuice/WhiteSur-gtk-theme/archive/refs/tags/2023-04-26.zip
unzip 2023-04-26.zip
tar -xf WhiteSur-gtk-theme-2023-04-26/release/WhiteSur-Dark-44-0.tar.xz
mv WhiteSur-Dark/ $HOME/../usr/share/themes/
rm -rf WhiteSur*
rm 2023-04-26.zip

#Install Fluent Cursor Icon Theme
wget https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/tags/2023-02-01.zip
unzip 2023-02-01.zip
mv Fluent-icon-theme-2023-02-01/cursors/dist $HOME/../usr/share/icons/ 
mv Fluent-icon-theme-2023-02-01/cursors/dist-dark $HOME/../usr/share/icons/
cp -r $HOME/../usr/share/icons/dist-dark $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/icons/dist-dark
rm -rf $HOME//Fluent*
rm 2023-02-01.zip

cat <<'EOF' > $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.Xresources
Xcursor.theme: dist-dark
EOF

#Setup Fonts
wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
mkdir .fonts 
mkdir $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/
unzip CascadiaCode-2111.01.zip
mv otf/static/* .fonts/ && rm -rf otf
mv ttf/* .fonts/ && rm -rf ttf/
rm -rf woff2/ && rm -rf CascadiaCode-2111.01.zip

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip
unzip Meslo.zip
mv *.ttf .fonts/
rm Meslo.zip
rm LICENSE.txt
rm readme.md

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/NotoColorEmoji-Regular.ttf
mv NotoColorEmoji-Regular.ttf .fonts
cp .fonts/NotoColorEmoji-Regular.ttf $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/ 

#Setup Fancybash Termux
wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/fancybash.sh
mv fancybash.sh .fancybash.sh
echo "source $HOME/.fancybash.sh" >> $HOME/.bashrc
sed -i "326s/\\\u/$username/" $HOME/.fancybash.sh
sed -i "327s/\\\h/termux/" $HOME/.fancybash.sh

#Setup Fancybash Proot
cp .fancybash.sh $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username
echo "source ~/.fancybash.sh" >> $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc
sed -i '327s/termux/proot/' $HOME/../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fancybash.sh

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/font.ttf
mv font.ttf .termux/font.ttf
}

setup_xfce_settings() {
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/conky.tar.gz
tar -xvzf conky.tar.gz
rm conky.tar.gz
mkdir ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config
mv .config/conky/ ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config
mv .config/neofetch ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/config.tar.gz
tar -xvzf config.tar.gz
rm config.tar.gz
chmod u+rwx .config/autostart/conky.desktop
chmod u+rwx .config/autostart/org.flameshot.Flameshot.desktop
}

setup_proot
setup_xfce
setup_termux_x11
setup_theme
setup_xfce_settings

rm setup.sh
source .bashrc
termux-reload-settings

########
##Finish ##
########

clear -x
echo ""
echo ""
echo "Setup completed successfully!"
echo ""
echo "You can now connect to your Termux XFCE4 Desktop to open the desktop use the command start"
echo ""
echo "This will start the termux-x11 server in termux and start the XFCE Desktop and then open the installed Termux-X11 app."
echo ""
echo "To exit, double click the Kill Termux X11 icon on the desktop."
echo ""
echo "Enjoy your Termux XFCE4 Desktop experience!"
echo ""
echo ""
