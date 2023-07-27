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

termux-setup-storage

clear -x

echo ""
echo "This script will install XFCE Desktop in Termux along with a Debian proot"
echo ""
read -r -p "Please enter username for proot installation: " username </dev/tty

timezone=$(getprop persist.sys.timezone)

#Fix Potential dbus Issues
pkg uninstall dbus -y
pkg install dbus -y

#Install requirements
pkg install x11-repo tur-repo pulseaudio -y

#Install XFCE4 Desktop and Extras
pkg install git neofetch virglrenderer-android proot-distro papirus-icon-theme xfce4 xfce4-goodies pavucontrol-qt exa bat wmctrl tigervnc firefox -y

#Setup Debian Proot
proot-distro install debian
proot-distro login debian --shared-tmp -- env DISPLAY=:1 apt update
proot-distro login debian --shared-tmp -- env DISPLAY=:1 apt upgrade -y
proot-distro login debian --shared-tmp -- env DISPLAY=:1 apt install sudo wget -y

#Create Debian Proot User
proot-distro login debian --shared-tmp -- env DISPLAY=:1 groupadd storage
proot-distro login debian --shared-tmp -- env DISPLAY=:1 groupadd wheel
proot-distro login debian --shared-tmp -- env DISPLAY=:1 groupadd video || true
proot-distro login debian --shared-tmp -- env DISPLAY=:1 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"

#Add User to sudoers
chmod u+rw ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w  ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

#Set Timezone
timezone=$(getprop persist.sys.timezone)
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime

#Set Display in Proot .bashrc
echo "export DISPLAY=:1.0" >> ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

############################
##Setup XFCE4 Desktop Theme and Sound##
############################

#Create .bashrc
cp ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/skel/.bashrc ~/.bashrc

#Enable Sound
echo "pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
" > ~/.sound
echo "source ~/.sound" >> ~/.bashrc

#Download Wallpaper
wget https://besthqwallpapers.com/Uploads/22-9-2017/21311/gray-lines-geometry-strips-dark-material-art.jpg
mv gray-lines-geometry-strips-dark-material-art.jpg ../usr/share/backgrounds/xfce/

#Install WhiteSur-Dark Theme
wget https://github.com/vinceliuice/WhiteSur-gtk-theme/archive/refs/tags/2023-04-26.zip
unzip 2023-04-26.zip
tar -xf WhiteSur-gtk-theme-2023-04-26/release/WhiteSur-Dark-44-0.tar.xz
mv WhiteSur-Dark/ ../usr/share/themes/
rm -rf WhiteSur*
rm 2023-04-26.zip

#Install Fluent Cursor Icon Theme
wget https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/tags/2023-02-01.zip
unzip 2023-02-01.zip
mv Fluent-icon-theme-2023-02-01/cursors/dist ../usr/share/icons/ && mv Fluent-icon-theme-2023-02-01/cursors/dist-dark ../usr/share/icons/
rm -rf ~/Fluent*
rm 2023-02-01.zip

#Setup Fonts
wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
mkdir .fonts 
unzip CascadiaCode-2111.01.zip
mv otf/static/* .fonts/ && rm -rf otf
mv ttf/* .fonts/ && rm -rf ttf/
rm -rf woff2/ && rm -rf CascadiaCode-2111.01.zip

#Setup Fancybash Termux
wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/fancybash.sh
mv fancybash.sh .fancybash.sh
echo "source ~/.fancybash.sh" >> .bashrc
sed -i "326s/\\\u/$username/" ~/.fancybash.sh
sed -i "327s/\\\h/termux/" ~/.fancybash.sh

#Setup Fancybash Proot
cp .fancybash.sh ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username
echo "source ~/.fancybash.sh" >> ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc
sed -i '327s/termux/proot/' ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fancybash.sh

#Set aliases
echo "
alias debian='proot-distro login debian --user $username --shared-tmp && clear'
alias virgl='GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=3.3 $@'
alias ls='exa -lF'
alias cat='bat $@'
" >> ~/.bashrc

#Set proot aliases

echo "
alias virgl='GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=3.3 $@'
alias ls='exa -lF'
alias cat='bat $@'
" >> ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Install Termux-X11

sed -i '12s/^#//' .termux/termux.properties
#wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/termux-x11.zip 
#unzip termux-x11.zip
#mv termux-x11.apk storage/downloads/
#apt install ./termux-x11-1.02.07-0-all.deb
#rm termux-x11.zip
#rm termux-x11-1.02.07-0-all.deb
#termux-open storage/downloads/termux-x11.apk

curl -sL https://nightly.link/termux/termux-x11/workflows/debug_build/master/termux-companion%20packages.zip -o termux_companion_packages.zip
unzip termux_companion_packages.zip "termux-x11-nightly*.deb"
mv termux-x11-nightly*.deb termux-x11-nightly.deb
dpkg -i termux-x11-nightly.deb
rm termux_companion_packages.zip termux-x11-nightly.deb

curl -sL https://nightly.link/termux/termux-x11/workflows/debug_build/master/termux-x11-universal-debug.zip -o termux-x11.zip
unzip termux-x11.zip
termux-open app-universal-debug.apk
rm termux-x11.zip app-universal-debug.apk

mkdir -p ~/Desktop

#XFCE Start
cat <<'EOF' > start
#!/bin/bash
termux-x11 :1.0 &
virgl_test_server_android &
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity && env DISPLAY=:1.0 dbus-launch --exit-with-session glxfce &

EOF

chmod +x start
mv start ../usr/bin

#glxfce Hardware Acceleration XFCE Desktop
cat <<'EOF' > glxfce
#!/bin/bash

export DISPLAY=:1
GALLIUM_DRIVER=virpipe xfce4-session &

EOF

chmod +x glxfce
mv glxfce ../usr/bin

#Shutdown Utility
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

#App-Installer Utility

git clone https://github.com/phoenixbyrd/App-Installer.git

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=App Installer
Comment=
Exec=/data/data/com.termux/files/home/App-Installer/app-installer
Icon=package-install
Path=
Terminal=false
StartupNotify=false
" > ~/Desktop/App-Installer.desktop

#Setup VNC

vncserver
vncserver -kill :1

sed -i '7s/.*/#/' ~/.vnc/xstartup
sed -i '11s/.*/xfce4-session \&/' ~/.vnc/xstartup

cat <<'EOF' > ../usr/bin/vncstart
#!/bin/bash

rm -rf ../usr/tmp/.X1*
vncserver

EOF

chmod +x ../usr/bin/vncstart

cat <<'EOF' > ../usr/bin/vncstop
#!/bin/bash

vncserver -kill :1

EOF

chmod +x ../usr/bin/vncstop

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Kill vncserver
Comment=
Exec=vncstop
Icon=system-shutdown
Path=
Terminal=false
StartupNotify=false
" > ~/Desktop/kill_vncserver.desktop

#Install Webcord
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/SpacingBat3/WebCord/releases/download/v4.2.0/webcord_4.2.0_arm64.deb
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0  apt install ./webcord_4.2.0_arm64.deb -y
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm webcord_4.2.0_arm64.deb

echo "[Desktop Entry]
Name=Discord
Comment=A Discord and Fosscord client made with the Electron API.
GenericName=Internet Messenger
Exec=proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 webcord --no-sandbox
Icon=discord
Type=Application
StartupNotify=true
Categories=Network;InstantMessaging;
" > ~/Desktop/webcord.desktop

chmod +x ~/Desktop/webcord.desktop
cp ~/Desktop/webcord.desktop ../usr/share/applications/webcord.desktop 

#Put Firefox icon on Desktop
cp ../usr/share/applications/firefox.desktop ~/Desktop 

##############
##XFCE4 SETTINGS##
##############

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


########
##Finish ##
########

clear -x
echo ""
echo ""
echo "Setup completed successfully!"
echo ""
echo "You can now connect to your Termux XFCE4 Desktop after restarting termux."
echo ""
echo "To open the desktop use the command start"
echo ""
echo "This will start the termux-x11 server in termux and start the XFCE Desktop open the installed Termux-X11 app."
echo ""
echo "To use start vnc use command vncstart and to shutdown vnc use command vncstop"
echo ""
echo "Enjoy your Termux XFCE4 Desktop experience!"
echo ""
echo ""

rm setup.sh
