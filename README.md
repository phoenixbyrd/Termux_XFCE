# Termux_XFCE

Sets up a termux XFCE desktop and a Debian proot install and installs some additional software like Vivaldi, Firefox, Libreoffice, Audacious, Webcord and a few others. 

You only need to pick your username and follow the prompts to create a vncserver password and a password for proot user. Comes already themed too.

#cp2menu

A companion script for this setup to make it easier to add apps installed into debian proot to be added to the termux xfce menu. It'll ls the applications directory so you can see all the .desktop files and all you need to do is write the full name of the .desktop file and it'll copy it to the termux applications folder and do the required editing to make them executable through termux using the command proot-distro login debian --user YOUR_USERNAME --shared-tmp -- env DISPLAY=:1.0 APP_NAME