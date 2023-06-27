#!/bin/bash

# Function to print centered text with margin and color
print_centered_text() {
  local text="$1"
  local margin_width=5  # Desired margin width
  local terminal_width=$(tput cols 2>/dev/null)  # Get the width of the terminal

  # Check if tput is available
  if [[ -z $terminal_width ]]; then
    terminal_width=80  # Default terminal width if tput is not available
  fi

  # Calculate the available width for the centered text
  local available_width=$((terminal_width - (2 * margin_width)))

  # Wrap the text to fit the available width
  local wrapped_text=$(echo "$text" | fold -s -w "$available_width")

  # Split the wrapped text into lines
  IFS=$'\n' read -d '' -r -a lines <<< "$wrapped_text"

  # Print the centered and wrapped lines with margin and color
  for line in "${lines[@]}"; do
    local indent=$(( (terminal_width - ${#line}) / 2 ))
    printf "%*s\e[1m%s\e[0m%*s\n" $margin_width "" "$line" $((margin_width + indent)) ""
  done
}

# Change to home directory and clear the screen
cd
clear

# Install ncurses-utils package
apt update > /dev/null 2>&1
apt install ncurses-utils -y > /dev/null 2>&1

echo ""
echo ""
print_centered_text ""
print_centered_text ""
print_centered_text "This install script will set up Termux with an XFCE4 Desktop and a Debian proot-distro install"

# Prompt for username
echo ""
echo ""
read -p "Please enter a username: " varname

#Setup phone storage access

termux-setup-storage

#Setup XFCE4 in Termux

apt install x11-repo && apt install git neofetch proot-distro papirus-icon-theme evince xfce4 xfce4-goodies pavucontrol-qt epiphany exa bat lynx cmatrix nyancat gimp hexchat audacious wmctrl -y

#Setup Debian Proot

proot-distro install debian && proot-distro login debian --shared-tmp -- env DISPLAY=:1 apt update && proot-distro login debian --shared-tmp -- env DISPLAY=:1 apt install sudo -y && proot-distro login debian --shared-tmp -- env DISPLAY=:1 adduser $varname

#Add user to sudoers

chmod u+rw ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$varname ALL=(ALL) NOPASSWD:ALL" | tee -a ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

#Install Additional Software as user

proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1 sudo apt install zenity onboard firefox-esr libreoffice wget curl vlc pithos apt-utils -y

#Set localtime

TZ=$(getprop persist.sys.timezone)

proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$TZ /etc/localtime

#Add Programs to Menu

#Firefox-ESR
cp ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/firefox-esr.desktop ../usr/share/applications && sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 \1/"  ../usr/share/applications/firefox-esr.desktop

#LibreOffice
cp ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/libreoffice* ../usr/share/applications && sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 \1/"   ../usr/share/applications/libreoffice*

#Onboard
cp ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/onboard.desktop ../usr/share/applications && sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 \1/"  ../usr/share/applications/onboard.desktop

#Install Brave Web Browser

proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 sudo tee /etc/apt/sources.list.d/brave-browser-release.list
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 sudo apt update && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 sudo apt install brave-browser -y

#Create Desktop Folder

mkdir ~/Desktop

#Create Desktop Launcher

echo "[Desktop Entry]
Version=1.0
Name=Brave Web Browser
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 /usr/bin/brave-browser-stable %U --no-sandbox
StartupNotify=true
Terminal=false
Icon=brave-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns;
Actions=new-window;new-private-window;
Path=
[Desktop Action new-window]
Name=New Window
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 /usr/bin/brave-browser-stable
[Desktop Action new-private-window]
Name=New Incognito Window
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 /usr/bin/brave-browser-stable --incognito
" > ~/Desktop/Brave.desktop

chmod +x ~/Desktop/Brave.desktop
cp ~/Desktop/Brave.desktop ../usr/share/applications/Brave.desktop 

# Install FreeTube

proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/FreeTubeApp/FreeTube/releases/download/v0.18.0-beta/freetube_0.18.0_arm64.deb && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 sudo apt install ./freetube_0.18.0_arm64.deb && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm freetube_0.18.0_arm64.deb

echo "[Desktop Entry]
Name=FreeTube
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 /opt/FreeTube/freetube %U --no-sandbox
Terminal=false
Type=Application
Icon=freetube
StartupWMClass=FreeTube
Comment=A private YouTube client
MimeType=x-scheme-handler/freetube;
Categories=Network;
" > ~/Desktop/freetube.desktop

chmod +x ~/Desktop/freetube.desktop
cp ~/Desktop/freetube.desktop ../usr/share/applications/freetube.desktop 

#Install Tor Browser

proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 wget https://sourceforge.net/projects/tor-browser-ports/files/12.0.6/tor-browser-linux-arm64-12.0.6_ALL.tar.xz/download -O tor.tar.xz
proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 tar -xvf tor.tar.xz 
proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 rm tor.tar.xz

#Create Desktop Launcher

echo "[Desktop Entry]
Type=Application
Name=Tor Browser
GenericName=Web Browser
Comment=Tor Browser  is +1 for privacy and −1 for mass surveillance
Categories=Network;WebBrowser;Security;
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 tor-browser/Browser/start-tor-browser
X-TorBrowser-ExecShell=./Browser/start-tor-browser --detach
Icon=tor
StartupWMClass=Tor Browser
Path=
Terminal=false
StartupNotify=false
" > ~/Desktop/tor.desktop

chmod +x ~/Desktop/tor.desktop
cp ~/Desktop/tor.desktop ../usr/share/applications/tor.desktop 

#Install Webcord

proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/SpacingBat3/WebCord/releases/download/v4.2.0/webcord_4.2.0_arm64.deb && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0  sudo -S apt install ./webcord_4.2.0_arm64.deb -y && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm webcord_4.2.0_arm64.deb

#Create Desktop Launcher

echo "[Desktop Entry]
Name=Discord
Comment=A Discord and Fosscord client made with the Electron API.
GenericName=Internet Messenger
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 webcord --no-sandbox
Icon=discord
Type=Application
StartupNotify=true
Categories=Network;InstantMessaging;
" > ~/Desktop/webcord.desktop

chmod +x ~/Desktop/webcord.desktop
cp ~/Desktop/webcord.desktop ../usr/share/applications/webcord.desktop 

#Install Visual Studio Code

proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 wget https://packages.microsoft.com/repos/code/pool/main/c/code/code_1.79.0-1686148160_arm64.deb -O code.deb && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0  sudo -S apt install ./code.deb -y && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm code.deb

#Create Desktop Launcher

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Visual Studio Code
Comment=Code Editing. Redefined.
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 /usr/share/code/code --no-sandbox
Icon=visual-studio-code
Path=
Terminal=false
StartupNotify=false

" > ~/Desktop/code.desktop

chmod +x ~/Desktop/code.desktop
cp ~/Desktop/code.desktop ../usr/share/applications/code.desktop 

#update and upgrade 
apt update && apt upgrade -y

#Install Fluent Cursor Icon Theme

wget https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/tags/2023-02-01.zip
unzip 2023-02-01.zip
mv Fluent-icon-theme-2023-02-01/cursors/dist ../usr/share/icons/ && mv Fluent-icon-theme-2023-02-01/cursors/dist-dark ../usr/share/icons/
rm -rf ~/Fluent*
rm 2023-02-01.zip

#Install WhiteSur-Dark Theme

wget https://github.com/vinceliuice/WhiteSur-gtk-theme/archive/refs/tags/2023-04-26.zip
unzip 2023-04-26.zip
tar -xf WhiteSur-gtk-theme-2023-04-26/release/WhiteSur-Dark-44-0.tar.xz
mv WhiteSur-Dark/ ../usr/share/themes/
rm -rf WhiteSur*
rm 2023-04-26.zip

#Download wallpaper
wget https://besthqwallpapers.com/Uploads/22-9-2017/21311/gray-lines-geometry-strips-dark-material-art.jpg
mv gray-lines-geometry-strips-dark-material-art.jpg ../usr/share/backgrounds/xfce/

#Create .bashrc

cp ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/skel/.bashrc ~/.bashrc

#Enable Sound

echo "pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
" > .sound
echo "source ~/.sound" >> ~/.bashrc

#Setup Fancybash Termux

wget https://raw.githubusercontent.com/ChrisTitusTech/scripts/master/fancy-bash-promt.sh
mv fancy-bash-promt.sh .fancybash.sh
echo "source ~/.fancybash.sh" >> .bashrc
sed -i "326s/\\\u/$varname/" ~/.fancybash.sh
sed -i "327s/\\\h/termux/" ~/.fancybash.sh

#Setup Fancybash Proot
cp .fancybash.sh ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$varname
echo "source ~/.fancybash.sh" >> ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$varname/.bashrc
sed -i '327s/termux/proot/' ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$varname/.fancybash.sh

echo "
# Run once script
run_once_script() {
  if [ ! -f ~/.run_once_completed ]; then
    wmctrl -n 1
    touch ~/.run_once_completed
  fi
}
run_once_script
" >> ~/.bashrc 

#Set Display in proot .bashrc

echo "export DISPLAY=:1.0" >> ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$varname/.bashrc

#Setup Fonts

wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
mkdir .fonts 
unzip CascadiaCode-2111.01.zip
mv otf/static/* .fonts/ && rm -rf otf
mv ttf/* .fonts/ && rm -rf ttf/
rm -rf woff2/ && rm -rf CascadiaCode-2111.01.zip

# Install Termux-X11
 
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/termux-x11.zip 
unzip termux-x11.zip
mv termux-x11.apk storage/downloads/
apt install ./termux-x11-1.02.07-0-all.deb
rm termux-x11.zip
rm termux-x11-1.02.07-0-all.deb

sed -i '12s/^#//' .termux/termux.properties
termux-open storage/downloads/termux-x11.apk

#XFCE Terminal Settings

mkdir -p ~/.config/xfce4/terminal/

cat <<EOF > .config/xfce4/terminal/terminalrc
[Configuration]
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
MiscSlimTabs=FALSE
MiscNewTabAdjacent=FALSE
MiscSearchDialogOpacity=100
MiscShowUnsafePasteDialog=TRUE
MiscRightClickAction=TERMINAL_RIGHT_CLICK_ACTION_CONTEXT_MENU
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
BackgroundDarkness=0.900000
ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#739fcf;#ad7fa8;#34e2e2;#eeeeec
ColorBackground=#291f291f340d
TitleMode=TERMINAL_TITLE_HIDE
ScrollingUnlimited=TRUE
ScrollingBar=TERMINAL_SCROLLBAR_NONE
EOF

#Create XFCE Files

mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/

cat <<EOF > .config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="WhiteSur-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="DoubleClickTime" type="empty"/>
    <property name="DoubleClickDistance" type="empty"/>
    <property name="DndDragThreshold" type="empty"/>
    <property name="CursorBlink" type="empty"/>
    <property name="CursorBlinkTime" type="empty"/>
    <property name="SoundThemeName" type="empty"/>
    <property name="EnableEventSounds" type="empty"/>
    <property name="EnableInputFeedbackSounds" type="empty"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="96"/>
    <property name="Antialias" type="empty"/>
    <property name="Hinting" type="empty"/>
    <property name="HintStyle" type="empty"/>
    <property name="RGBA" type="empty"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="empty"/>
    <property name="ColorPalette" type="empty"/>
    <property name="FontName" type="empty"/>
    <property name="MonospaceFontName" type="empty"/>
    <property name="IconSizes" type="empty"/>
    <property name="KeyThemeName" type="empty"/>
    <property name="ToolbarStyle" type="empty"/>
    <property name="ToolbarIconSize" type="empty"/>
    <property name="MenuImages" type="empty"/>
    <property name="ButtonImages" type="empty"/>
    <property name="MenuBarAccel" type="empty"/>
    <property name="CursorThemeName" type="string" value="dist-dark"/>
    <property name="CursorThemeSize" type="int" value="32"/>
    <property name="DecorationLayout" type="empty"/>
    <property name="DialogsUseHeader" type="empty"/>
    <property name="TitlebarMiddleClick" type="empty"/>
  </property>
  <property name="Gdk" type="empty">
    <property name="WindowScalingFactor" type="empty"/>
  </property>
  <property name="Xfce" type="empty">
    <property name="LastCustomDPI" type="int" value="96"/>
    <property name="SyncThemes" type="bool" value="true"/>
  </property>
</channel>

EOF

cat << EOF >  .config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="activate_action" type="string" value="bring"/>
    <property name="borderless_maximize" type="bool" value="true"/>
    <property name="box_move" type="bool" value="false"/>
    <property name="box_resize" type="bool" value="false"/>
    <property name="button_layout" type="string" value="O|SHMC"/>
    <property name="button_offset" type="int" value="0"/>
    <property name="button_spacing" type="int" value="0"/>
    <property name="click_to_focus" type="bool" value="true"/>
    <property name="cycle_apps_only" type="bool" value="false"/>
    <property name="cycle_draw_frame" type="bool" value="true"/>
    <property name="cycle_raise" type="bool" value="false"/>
    <property name="cycle_hidden" type="bool" value="true"/>
    <property name="cycle_minimum" type="bool" value="true"/>
    <property name="cycle_minimized" type="bool" value="false"/>
    <property name="cycle_preview" type="bool" value="true"/>
    <property name="cycle_tabwin_mode" type="int" value="0"/>
    <property name="cycle_workspaces" type="bool" value="false"/>
    <property name="double_click_action" type="string" value="maximize"/>
    <property name="double_click_distance" type="int" value="5"/>
    <property name="double_click_time" type="int" value="250"/>
    <property name="easy_click" type="string" value="Alt"/>
    <property name="focus_delay" type="int" value="250"/>
    <property name="focus_hint" type="bool" value="true"/>
    <property name="focus_new" type="bool" value="true"/>
    <property name="frame_opacity" type="int" value="100"/>
    <property name="frame_border_top" type="int" value="0"/>
    <property name="full_width_title" type="bool" value="true"/>
    <property name="horiz_scroll_opacity" type="bool" value="false"/>
    <property name="inactive_opacity" type="int" value="100"/>
    <property name="maximized_offset" type="int" value="0"/>
    <property name="mousewheel_rollup" type="bool" value="true"/>
    <property name="move_opacity" type="int" value="100"/>
    <property name="placement_mode" type="string" value="center"/>
    <property name="placement_ratio" type="int" value="20"/>
    <property name="popup_opacity" type="int" value="100"/>
    <property name="prevent_focus_stealing" type="bool" value="false"/>
    <property name="raise_delay" type="int" value="250"/>
    <property name="raise_on_click" type="bool" value="true"/>
    <property name="raise_on_focus" type="bool" value="false"/>
    <property name="raise_with_any_button" type="bool" value="true"/>
    <property name="repeat_urgent_blink" type="bool" value="false"/>
    <property name="resize_opacity" type="int" value="100"/>
    <property name="scroll_workspaces" type="bool" value="true"/>
    <property name="shadow_delta_height" type="int" value="0"/>
    <property name="shadow_delta_width" type="int" value="0"/>
    <property name="shadow_delta_x" type="int" value="0"/>
    <property name="shadow_delta_y" type="int" value="-3"/>
    <property name="shadow_opacity" type="int" value="50"/>
    <property name="show_app_icon" type="bool" value="false"/>
    <property name="show_dock_shadow" type="bool" value="true"/>
    <property name="show_frame_shadow" type="bool" value="true"/>
    <property name="show_popup_shadow" type="bool" value="false"/>
    <property name="snap_resist" type="bool" value="false"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="false"/>
    <property name="snap_width" type="int" value="10"/>
    <property name="vblank_mode" type="string" value="auto"/>
    <property name="theme" type="string" value="WhiteSur-Dark"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="title_font" type="string" value="Sans Bold 9"/>
    <property name="title_horizontal_offset" type="int" value="0"/>
    <property name="titleless_maximize" type="bool" value="false"/>
    <property name="title_shadow_active" type="string" value="false"/>
    <property name="title_shadow_inactive" type="string" value="false"/>
    <property name="title_vertical_offset_active" type="int" value="0"/>
    <property name="title_vertical_offset_inactive" type="int" value="0"/>
    <property name="toggle_workspaces" type="bool" value="false"/>
    <property name="unredirect_overlays" type="bool" value="true"/>
    <property name="urgent_blink" type="bool" value="false"/>
    <property name="use_compositing" type="bool" value="true"/>
    <property name="workspace_count" type="int" value="4"/>
    <property name="wrap_cycle" type="bool" value="true"/>
    <property name="wrap_layout" type="bool" value="true"/>
    <property name="wrap_resistance" type="int" value="10"/>
    <property name="wrap_windows" type="bool" value="true"/>
    <property name="wrap_workspaces" type="bool" value="false"/>
    <property name="zoom_desktop" type="bool" value="true"/>
    <property name="zoom_pointer" type="bool" value="true"/>
    <property name="workspace_names" type="array">
      <value type="string" value="Workspace 1"/>
      <value type="string" value="Workspace 2"/>
      <value type="string" value="Workspace 3"/>
      <value type="string" value="Workspace 4"/>
    </property>
  </property>
</channel>

EOF

cat <<EOF > .config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="double" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="icon-size" type="uint" value="32"/>
      <property name="size" type="uint" value="40"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="13"/>
        <value type="int" value="4"/>
        <value type="int" value="7"/>
        <value type="int" value="1"/>
        <value type="int" value="14"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="11"/>
        <value type="int" value="12"/>
        <value type="int" value="8"/>
        <value type="int" value="9"/>
      </property>
      <property name="length-adjust" type="bool" value="true"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-rgba" type="array">
        <value type="double" value="0.75"/>
        <value type="double" value="0.25"/>
        <value type="double" value="0.25"/>
        <value type="double" value="0"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu">
      <property name="button-icon" type="string" value="distributor-logo-android"/>
      <property name="show-button-title" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="grouping" type="bool" value="false"/>
      <property name="sort-order" type="uint" value="0"/>
      <property name="show-handle" type="bool" value="true"/>
      <property name="show-labels" type="bool" value="false"/>
    </property>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-5" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-6" type="string" value="systray">
      <property name="square-icons" type="bool" value="true"/>
    </property>
    <property name="plugin-11" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-12" type="string" value="clock">
      <property name="digital-layout" type="uint" value="3"/>
      <property name="digital-time-format" type="string" value="%I:%M %p"/>
      <property name="digital-time-font" type="string" value="Sans 12"/>
    </property>
    <property name="plugin-13" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-7" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-8" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-9" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-14" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
  </property>
</channel>


EOF

cat <<EOF > .config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="../usr/share/backgrounds/xfce/gray-lines-geometry-strips-dark-material-art.jpg"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="../usr/share/backgrounds/xfce/xfce-shapes.svg"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="../usr/share/backgrounds/xfce/xfce-shapes.svg"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="../usr/share/backgrounds/xfce/xfce-shapes.svg"/>
        </property>
      </property>
      <property name="monitorscreen" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/data/data/com.termux/files/usr/share/backgrounds/xfce/gray-lines-geometry-strips-dark-material-art.jpg"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/data/data/com.termux/files/usr/share/backgrounds/xfce/xfce-shapes.svg"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/data/data/com.termux/files/usr/share/backgrounds/xfce/xfce-shapes.svg"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/data/data/com.termux/files/usr/share/backgrounds/xfce/xfce-shapes.svg"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-home" type="bool" value="false"/>
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-trash" type="bool" value="false"/>
    </property>
  </property>
  <property name="last" type="empty">
    <property name="window-width" type="int" value="653"/>
    <property name="window-height" type="int" value="554"/>
  </property>
</channel>

EOF

mkdir -p .config/Mousepad

cat <<EOF > .config/Mousepad/accels.scm
; mousepad GtkAccelMap rc-file         -*- scheme -*-
; this file is an automated accelerator map dump
;
; (gtk_accel_path "<Actions>/app.mousepad-plugin-shortcuts" "")
; (gtk_accel_path "<Actions>/win.edit.convert.spaces-to-tabs" "")
; (gtk_accel_path "<Actions>/app.preferences.view.smart-backspace" "")
; (gtk_accel_path "<Actions>/app.preferences.view.highlight-current-line" "")
; (gtk_accel_path "<Actions>/app.preferences.file.make-backup" "")
; (gtk_accel_path "<Actions>/win.preferences.window.toolbar-visible" "")
; (gtk_accel_path "<Actions>/app.preferences.window.client-side-decorations" "")
; (gtk_accel_path "<Actions>/win.search.find-and-replace" "<Primary>r")
; (gtk_accel_path "<Actions>/win.file.save-all" "")
; (gtk_accel_path "<Actions>/win.edit.duplicate-line-selection" "")
; (gtk_accel_path "<Actions>/win.edit.move.line-up" "<Alt>Up")
; (gtk_accel_path "<Actions>/win.edit.convert.transpose" "<Primary>t")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(4)" "<Alt>5")
; (gtk_accel_path "<Actions>/win.edit.undo" "<Primary>z")
; (gtk_accel_path "<Actions>/win.file.save-as" "<Primary><Shift>s")
; (gtk_accel_path "<Actions>/app.preferences.window.remember-size" "")
; (gtk_accel_path "<Actions>/app.preferences" "")
; (gtk_accel_path "<Actions>/win.edit.convert.tabs-to-spaces" "")
; (gtk_accel_path "<Actions>/app.preferences.window.remember-state" "")
; (gtk_accel_path "<Actions>/app.preferences.window.path-in-title" "")
; (gtk_accel_path "<Actions>/win.view.fullscreen" "F11")
; (gtk_accel_path "<Actions>/win.document.previous-tab" "<Primary>Page_Up")
; (gtk_accel_path "<Actions>/app.preferences.view.show-whitespace.inside" "")
; (gtk_accel_path "<Actions>/win.file.new-window" "<Primary><Shift>n")
; (gtk_accel_path "<Actions>/app.state.search.incremental" "")
; (gtk_accel_path "<Actions>/app.preferences.view.show-whitespace" "")
; (gtk_accel_path "<Actions>/app.preferences.view.use-default-monospace-font" "")
; (gtk_accel_path "<Actions>/app.preferences.file.auto-reload" "")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(5)" "<Alt>6")
; (gtk_accel_path "<Actions>/win.reset-font-size" "<Primary>0")
; (gtk_accel_path "<Actions>/win.file.save" "<Primary>s")
; (gtk_accel_path "<Actions>/win.help.about" "")
; (gtk_accel_path "<Actions>/win.file.new" "<Primary>n")
; (gtk_accel_path "<Actions>/app.preferences.file.add-last-end-of-line" "")
; (gtk_accel_path "<Actions>/win.preferences.window.menubar-visible" "<Primary>m")
; (gtk_accel_path "<Actions>/win.search.find-previous" "<Primary><Shift>g")
; (gtk_accel_path "<Actions>/app.preferences.window.expand-tabs" "")
; (gtk_accel_path "<Actions>/win.file.detach-tab" "<Primary>d")
; (gtk_accel_path "<Actions>/app.state.search.highlight-all" "")
; (gtk_accel_path "<Actions>/win.edit.paste" "<Primary>v")
; (gtk_accel_path "<Actions>/app.preferences.view.show-whitespace.leading" "")
; (gtk_accel_path "<Actions>/win.edit.copy" "<Primary>c")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(6)" "<Alt>7")
; (gtk_accel_path "<Actions>/win.file.open-recent.new" "")
; (gtk_accel_path "<Actions>/win.file.close-window" "<Primary><Shift>w")
; (gtk_accel_path "<Actions>/win.file.new-from-template.new" "")
; (gtk_accel_path "<Actions>/win.edit.convert.strip-trailing-spaces" "")
; (gtk_accel_path "<Actions>/win.document.filetype" "")
; (gtk_accel_path "<Actions>/win.edit.paste-special.paste-from-history" "")
; (gtk_accel_path "<Actions>/win.view.select-font" "")
; (gtk_accel_path "<Actions>/win.edit.convert.to-lowercase" "")
; (gtk_accel_path "<Actions>/win.edit.convert.to-title-case" "")
; (gtk_accel_path "<Actions>/app.preferences.window.always-show-tabs" "")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(7)" "<Alt>8")
; (gtk_accel_path "<Actions>/win.search.find" "<Primary>f")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(0)" "<Alt>1")
; (gtk_accel_path "<Actions>/app.quit" "<Primary>q")
; (gtk_accel_path "<Actions>/win.file.close-tab" "<Primary>w")
; (gtk_accel_path "<Actions>/win.edit.increase-indent" "<Primary>i")
; (gtk_accel_path "<Actions>/app.preferences.view.show-line-endings" "")
; (gtk_accel_path "<Actions>/win.edit.delete-selection" "Delete")
; (gtk_accel_path "<Actions>/win.edit.move.word-left" "<Alt>Left")
; (gtk_accel_path "<Actions>/win.edit.delete-line" "<Primary><Shift>Delete")
; (gtk_accel_path "<Actions>/win.textview.menubar" "")
; (gtk_accel_path "<Actions>/win.file.open-recent.clear-history" "")
; (gtk_accel_path "<Actions>/win.document.viewer-mode" "")
; (gtk_accel_path "<Actions>/app.preferences.view.show-whitespace.trailing" "")
; (gtk_accel_path "<Actions>/win.file.reload" "")
; (gtk_accel_path "<Actions>/win.document.tab.tab-size" "")
; (gtk_accel_path "<Actions>/win.edit.move.line-down" "<Alt>Down")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(8)" "<Alt>9")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(1)" "<Alt>2")
; (gtk_accel_path "<Actions>/win.document.line-ending" "")
; (gtk_accel_path "<Actions>/win.search.go-to" "<Primary>l")
; (gtk_accel_path "<Actions>/app.preferences.view.color-scheme" "")
; (gtk_accel_path "<Actions>/app.preferences.view.show-line-numbers" "")
; (gtk_accel_path "<Actions>/win.edit.paste-special.paste-as-column" "")
; (gtk_accel_path "<Actions>/app.preferences.view.show-right-margin" "")
; (gtk_accel_path "<Actions>/app.preferences.window.remember-position" "")
; (gtk_accel_path "<Actions>/win.edit.cut" "<Primary>x")
; (gtk_accel_path "<Actions>/win.search.find-next" "<Primary>g")
; (gtk_accel_path "<Actions>/app.preferences.file.monitor-changes" "")
; (gtk_accel_path "<Actions>/app.preferences.view.match-braces" "")
; (gtk_accel_path "<Actions>/win.edit.decrease-indent" "<Primary>u")
; (gtk_accel_path "<Actions>/win.increase-font-size" "<Primary>plus")
; (gtk_accel_path "<Actions>/app.preferences.view.word-wrap" "")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(2)" "<Alt>3")
; (gtk_accel_path "<Actions>/app.preferences.view.insert-spaces" "")
; (gtk_accel_path "<Actions>/app.preferences.view.auto-indent" "")
; (gtk_accel_path "<Actions>/win.file.open" "<Primary>o")
; (gtk_accel_path "<Actions>/win.decrease-font-size" "<Primary>minus")
; (gtk_accel_path "<Actions>/win.file.print" "<Primary>p")
; (gtk_accel_path "<Actions>/win.document.next-tab" "<Primary>Page_Down")
; (gtk_accel_path "<Actions>/win.edit.move.word-right" "<Alt>Right")
; (gtk_accel_path "<Actions>/win.edit.select-all" "<Primary>a")
; (gtk_accel_path "<Actions>/win.edit.convert.to-uppercase" "")
; (gtk_accel_path "<Actions>/win.document.go-to-tab" "")
; (gtk_accel_path "<Actions>/win.preferences.window.statusbar-visible" "")
; (gtk_accel_path "<Actions>/win.edit.convert.to-opposite-case" "<Primary><Alt>u")
; (gtk_accel_path "<Actions>/app.preferences.window.cycle-tabs" "")
; (gtk_accel_path "<Actions>/app.preferences.view.indent-on-tab" "")
; (gtk_accel_path "<Actions>/win.help.contents" "F1")
; (gtk_accel_path "<Actions>/win.document.go-to-tab(3)" "<Alt>4")
; (gtk_accel_path "<Actions>/win.edit.redo" "<Primary>y")
; (gtk_accel_path "<Actions>/win.document.write-unicode-bom" "")
; (gtk_accel_path "<Actions>/app.preferences.window.toolbar-visible" "")

EOF

#Create .bash_aliases

echo "alias cls='clear -x'
alias prun='proot-distro login --user $varname debian --shared-tmp -- env DISPLAY=:1 $@'
alias debian='clear && proot-distro login debian --user $varname --shared-tmp && clear'
alias ls='exa -lF'
alias cat='bat $@'
alias x11='termux-x11 :1 &'
alias display='env DISPLAY=:1 dbus-launch --exit-with-session xfce4-session'
alias virgl='virgl_test_server_android &'
" > .bash_aliases

#Create .bash_aliases proot

echo "alias cls='clear -x'
alias ls='exa -lF'
alias cat='bat $@'
" > ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$varname/.bash_aliases

# create start command

cat <<'EOF' > start
#!/bin/bash
termux-x11 :1.0 &
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity && env DISPLAY=:1.0 dbus-launch --exit-with-session xfce4-session &

EOF

chmod +x start
mv start ../usr/bin

#Create cp2menu script and desktop launcher

cat <<'EOF' > cp2menu
#!/bin/bash

cd

user_dir="../usr/var/lib/proot-distro/installed-rootfs/debian/home/"

# Get the username from the user directory
username=$(basename "$user_dir"/*)

selected_file=$(zenity --file-selection --title="Select .desktop File" --file-filter="*.desktop" --filename="../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications")

if [[ -z $selected_file ]]; then
  zenity --info --text="No file selected. Quitting..." --title="Operation Cancelled"
  exit 0
fi

desktop_filename=$(basename "$selected_file")

cp "$selected_file" "../usr/share/applications/"
sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 \1/" "../usr/share/applications/$desktop_filename"

zenity --info --text="Operation completed successfully!" --title="Success"

EOF

chmod +x cp2menu
mv cp2menu ../usr/bin/cp2menu

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=cp2menu
Comment=
Exec=cp2menu
Icon=mail-move
Path=
Terminal=false
StartupNotify=false
" > ~/Desktop/cp2menu.desktop

chmod +x ~/Desktop/cp2menu.desktop

#Create backup script and desktop launcher

#!/bin/bash

cat <<'EOF' > ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/bin/backup_restore
#!/bin/bash

backup_dir_local="."  # Specify the local backup directory path
backup_dir_sdcard="/storage/emulated/0/Download/"  # Specify the SD card backup directory path
archive_file="backup.tar.gz"     # Specify the archive file name

function backup() {
    zenity --info --title="Backup" --width=300 --text="Creating backup archive..."
    tar -czf "$backup_dir_local/$archive_file" -C ~/.config BraveSoftware WebCord FreeTube
    zenity --info --title="Backup" --width=300 --text="Local backup completed!\n\nBackup path: $backup_dir_local/$archive_file"

    zenity --info --title="Backup" --width=300 --text="Creating backup archive on SD card..."
    tar -czf "$backup_dir_sdcard/$archive_file" -C ~/.config BraveSoftware WebCord FreeTube
    zenity --info --title="Backup" --width=300 --text="SD card backup completed!\n\nBackup path: $backup_dir_sdcard/$archive_file"
}

function restore() {
    restore_source=$(zenity --list --radiolist --title="Restore Source" --width=300 --height=200 --column "" --column "Source" FALSE "Local Backup" FALSE "SD Card Backup" --hide-header)
    case "$restore_source" in
        "Local Backup")
            restore_directory="$backup_dir_local"
            ;;
        "SD Card Backup")
            restore_directory="$backup_dir_sdcard"
            ;;
        *)
            echo "No restore source selected."
            return
            ;;
    esac

    if [ -f "$restore_directory/$archive_file" ]; then
        zenity --info --title="Restore" --width=300 --text="Restoring..."
        rm -rf ~/.config/BraveSoftware ~/.config/WebCord ~/.config/FreeTube
        tar -xzf "$restore_directory/$archive_file" -C ~/.config
        zenity --info --title="Restore" --width=300 --text="Restoration completed!"
    else
        zenity --info --title="Restore" --width=300 --text="No backup archive found in the selected restore source. Unable to restore!"
    fi
}

function show_backup_dialog() {
    zenity --info --title="Backup" --width=300 --text="Click OK to create a backup.\n\nThis will take a few moments."
    backup
}

function show_restore_dialog() {
    restore
}

# Display GUI dialog to select backup or restore
selection=$(zenity --list --radiolist --title="Backup and Restore" --width=300 --height=200 --column "" --column "Action" FALSE "Backup" FALSE "Restore" --hide-header)

case "$selection" in
    "Backup")
        show_backup_dialog
        ;;
    "Restore")
        show_restore_dialog
        ;;
    *)
        echo "No action selected."
        ;;
esac

EOF

chmod +x ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/bin/backup_restore

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Backup & Restore
Comment=
Exec=proot-distro login debian --user phoenixbyrd --shared-tmp -- env DISPLAY=:1.0 backup_restore
Icon=backup
Path=
Terminal=false
StartupNotify=false
" > ~/Desktop/backup_restore.desktop


cat <<'EOF' > ../usr/bin/kill_termux_x11
#!/bin/bash

# Get the process IDs of Termux-X11 and XFCE sessions
termux_x11_pid=$(pgrep -f "/system/bin/app_process / com.termux.x11.Loader :1")
xfce_pid=$(pgrep -f "xfce4-session")

# Check if the process IDs exist
if [ -n "$termux_x11_pid" ] && [ -n "$xfce_pid" ]; then
  # Kill the processes
  kill -9 "$termux_x11_pid" "$xfce_pid"
  echo "Termux-X11 and XFCE sessions closed."
else
  echo "Termux-X11 or XFCE session not found."
fi

EOF

chmod +x ../usr/bin/kill_termux_x11

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Kill Termux X11
Comment=
Exec=kill_termux_x11
Icon=system-shutdown
Path=
Terminal=false
StartupNotify=false
" > ~/Desktop/kill_termux_x11.desktop


# Display completion message and next steps
# Function to print centered text with margin
print_centered_text() {
  local text="$1"
  local margin_width=5  # Desired margin width
  local terminal_width=$(tput cols)  # Get the width of the terminal

  # Calculate the available width for the centered text
  local available_width=$((terminal_width - (2 * margin_width)))

  # Wrap the text to fit the available width
  local wrapped_text=$(echo "$text" | fold -s -w "$available_width")

  # Split the wrapped text into lines
  IFS=$'\n' read -d '' -r -a lines <<< "$wrapped_text"

  # Print the centered and wrapped lines with margin
  for line in "${lines[@]}"; do
    local indent=$(( (terminal_width - ${#line}) / 2 ))
    printf "%*s%s%*s\n" $margin_width "" "$line" $((margin_width + indent)) ""
  done
}

clear

# Display completion message and next steps

echo ""
echo ""
print_centered_text "Setup completed successfully!"
echo ""
print_centered_text "You can now connect to your Termux XFCE4 Desktop after restarting termux."
echo ""
print_centered_text "To open the desktop use the command start"
echo ""
print_centered_text "This will start the termux-x11 server in termux and start the XFCE Desktop open the installed Termux-X11 app."
echo ""
print_centered_text "After installing apps in proot, exit back into Termux and use the command cp2menu to move the application launchers into your XFCE menu or you can double click the icon on the desktop to launch the cp2menu script."
echo ""
print_centered_text "Enjoy your Termux XFCE4 Desktop experience!"
echo ""

rm setup.sh
