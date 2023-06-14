# Termux_XFCE

Sets up a termux XFCE desktop and a Debian proot install and installs some additional software like Vivaldi, Firefox, Libreoffice, Audacious, Webcord and a few others.

You only need to pick your username and follow the prompts to create a password for proot user. This will take just under 7.5GB of storage space.

This setup uses Termux-X11, the termux-x11 server will be installed and the Android APK will be placed in your Downloads directory, please manually install it. 

This is is how I personally use Termux on my Galaxy Fold 3, script was created mainly for personal use but also for others if they wanted to try out my setup. This is my daily driver used with a 15 inch Lepow portable monitor and bluetooth keyboard and mouse.

&nbsp;
# Starting the desktop

During install you will recieve a popup to allow installs from termux, this will open the APK for the Termux-X11 android app. While you do not have to allow installs from termux, you will still need to install manually by using a file browser and finding thhe APK in your downloads folder. 

After install you will need to exit termux using the command ```exit```
Once you restart termux you can use the command ```start``` 
This will start the termux-x11 server, XFCE4 desktop and open the Termux-X11 app right into the desktop. 

&nbsp;

# cp2menu

A companion script for this setup to make it easier to add apps installed into debian proot to be added to the termux xfce menu. 
I have noticed an issue with some things not wanting to show in the menu even with this script, those .desktop files will need to be manually edited by the user, however once moved you can also created a desktop launcher normally for that app and it will work as expected.

&nbsp;

# Backup & Restore

This script will back up and restore the installed Vivaldi and WebCord .config directories. 

&nbsp;

# Kill Termux X11

This script will shut down your session, you will have to manually close the Android apps

&nbsp;

# Install

To install run this command in termux

&nbsp;

```
pkg update && pkg upgrade && pkg install wget && wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

&nbsp;

![Desktop Screenshot](Desktop.png)
