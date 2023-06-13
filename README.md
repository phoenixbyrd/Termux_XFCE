# Termux_XFCE

Sets up a termux XFCE desktop and a Debian proot install and installs some additional software like Vivaldi, Firefox, Libreoffice, Audacious, Webcord and a few others.

You only need to pick your username and follow the prompts to create a vncserver password and a password for proot user. Comes already themed too. This will take just under 7.5GB of storage space.

# cp2menu

A companion script for this setup to make it easier to add apps installed into debian proot to be added to the termux xfce menu. 

# Backup & Restore

This script will back up and restore the installed Vivaldi and WebCord .config directories. 

# Install

To install run this command in termux

wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/setup.sh && chmod +x setup.sh && ./setup.sh

![Desktop Screenshot](Desktop.png)
