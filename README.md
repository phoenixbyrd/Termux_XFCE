# Termux_XFCE

Sets up a termux XFCE desktop and a Debian proot install and installs some additional software like Vivaldi, Firefox, Libreoffice, Audacious, Webcord and a few others.

You only need to pick your username and follow the prompts to create a password for proot user. This will take just under 7.5GB of storage space.

This setup uses Termux-X11, the termux-x11 server will be installed and the Android APK will be placed in your Downloads directory, please manually install it. 

This is is how I personally use Termux on my Galaxy Fold 3, script was created mainly for personal use but also for others if they wanted to try out my setup.

&nbsp;
# bash_aliases

These are some bash aliases I set, the most important ones to note are

```x11``` for starting the Termux-X11 server

```display``` for starting the XFCE desktop

```debian``` for accessing the Debian proot-distro

&nbsp;
  
alias cls='clear -x'

alias prun='proot-distro login --user phoenixbyrd debian --shared-tmp -- env DISPLAY=:1 '

alias debian='clear && proot-distro login debian --user phoenixbyrd --shared-tmp && clear'

alias ls='exa -lF'

alias cat='bat '

alias x11='termux-x11 :1 &'

alias display='env DISPLAY=:1 dbus-launch --exit-with-session xfce4-session'

alias virgl='virgl_test_server_android &'

&nbsp;

# cp2menu

A companion script for this setup to make it easier to add apps installed into debian proot to be added to the termux xfce menu. 

&nbsp;

# Backup & Restore

This script will back up and restore the installed Vivaldi and WebCord .config directories. 

&nbsp;

# Kill Termux X11

This script will shut down your session, you will have to manually close the Android apps

# Install

To install run this command in termux

&nbsp;

```
pkg update && pkg upgrade && pkg install wget && wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

&nbsp;

![Desktop Screenshot](Desktop.png)
