#!/bin/bash
echo "This install script will set up Termux with an XFCE4 Desktop and a Debian proot-distro install"

# Prompt for username
read -p "Please enter a username: " varname

cd

#Setup phone storage access

termux-setup-storage

#Setup XFCE4 in Termux

pkg update && pkg upgrade -y && pkg install x11-repo wget git neofetch proot-distro papirus-icon-theme virglrenderer-android tigervnc xfce4 xfce4-goodies xfce4-whiskermenu-plugin pavucontrol-qt epiphany exa bat lynx cmatrix nyancat gimp hexchat audacious -y && vncserver  && vncserver -kill :1

#Create XFCE Desktop file for vnc

echo "xfce4-session &
xhost + &
cp .Xauthority ../usr/var/lib/proot-distro/installed-rootfs/debian/home/$varname
" > .vnc/xstartup

#Setup Debian Proot

proot-distro install debian && proot-distro login debian --shared-tmp -- env DISPLAY=:1 apt update && proot-distro login debian --shared-tmp -- env DISPLAY=:1 apt install sudo -y && proot-distro login debian --shared-tmp -- env DISPLAY=:1 adduser $varname

#Add user to sudoers

chmod u+rw ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$varname ALL=(ALL) NOPASSWD:ALL" | tee -a ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w ../usr/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

#Install Additional Software as user

proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1 sudo apt install onboard firefox-esr libreoffice -y

#Set localtime to EST

proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime && proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/EST /etc/localtime

#Add Programs to Menu

#Firefox-ESR
cp ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/firefox-esr.desktop ../usr/share/applications && sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 \1/"  ../usr/share/applications/firefox-esr.desktop

#LibreOffice
cp ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/libreoffice* ../usr/share/applications && sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 \1/"   ../usr/share/applications/libreoffice*

#Onboard
cp ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/onboard.desktop ../usr/share/applications && sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 \1/"  ../usr/share/applications/onboard.desktop

#Install Vivaldi Web Browser

proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 wget https://downloads.vivaldi.com/stable/vivaldi-stable_6.0.2979.22-1_arm64.deb && proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0  sudo -S apt install ./vivaldi-stable_6.0.2979.22-1_arm64.deb -y && proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 rm vivaldi-stable_6.0.2979.22-1_arm64.deb

#Create Desktop Folder

mkdir ~/Desktop

#Create Desktop Launcher

echo "[Desktop Entry]
Name=Vivaldi
GenericName=Web Browser
Exec=proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 vivaldi --no-sandbox
StartupNotify=true
Terminal=false
Icon=vivaldi
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/ftp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/mailto;
" > ~/Desktop/vivaldi.desktop

chmod +x ~/Desktop/vivaldi.desktop
cp ~/Desktop/vivaldi.desktop ../usr/share/applications/vivaldi.desktop 

#Install Webcord

proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/SpacingBat3/WebCord/releases/download/v4.2.0/webcord_4.2.0_arm64.deb && proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0  sudo -S apt install ./webcord_4.2.0_arm64.deb -y && proot-distro login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 rm webcord_4.2.0_arm64.deb

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
echo "source .sound" >> .bashrc

#XFCE Terminal Settings

mkdir -p ~/ .config/xfce4/terminal/

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

#Create .bashaliases
echo "alias cls='clear -x'
alias prun='proot-distro login --user $varname debian --shared-tmp -- env DISPLAY=:1 $@'
alias debian='clear && proot-distro login debian --user $varname --shared-tmp && clear'
alias ls='exa -lF'
alias cat='bat $@'
alias x11='termux-x11 :1 &'
alias display='env DISPLAY=:1 dbus-launch --exit-with-session xfce4-session'
alias virgl='virgl_test_server_android &'
" > .bash_aliases

# Display completion message and next steps
echo "┌─────────────────────────────────────────┐"
echo "│     Setup completed successfully!       │"
echo "└─────────────────────────────────────────┘"
echo ""
echo "You can now connect to your Termux XFCE4 Desktop using a VNC viewer."
echo ""
echo "Start the VNC server by running:"
echo ""
echo "   vncserver"
echo ""
echo "To stop the VNC server, use the following command:"
echo ""
echo "   vncserver -kill :1"
echo ""
echo "Make note of the displayed VNC server address (e.g., localhost:1) for connecting with the VNC viewer."
echo ""
echo "Enjoy your Termux XFCE4 Desktop experience!"
echo ""
