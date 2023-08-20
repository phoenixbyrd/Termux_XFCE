# Termux_XFCE

Sets up a termux XFCE desktop and a Debian proot install.

You only need to pick your username and follow the prompts to create a password for vncserver. This will take roughly 3GB of storage space. Please note, this can be a lengthy process.

This setup uses Termux-X11, the termux-x11 server will be installed and you will be prompted to allow termux to install the Android APK. It will also setup vncserver.

This is is how I personally use Termux on my Galaxy Fold 3, script was created mainly for personal use but also for others if they wanted to try out my setup. This is my daily driver used with a 15 inch Lepow portable monitor and bluetooth keyboard and mouse.

&nbsp;

# Starting the desktop

During install you will recieve a popup to allow installs from termux, this will open the APK for the Termux-X11 android app. While you do not have to allow installs from termux, you will still need to install manually by using a file browser and finding the APK in your downloads folder. 
  
Use the command ```start``` to initiate a Termux-X11 session
  
This will start the termux-x11 server, XFCE4 desktop and open the Termux-X11 app right into the desktop. 

To start vnc use the command ```vncstart``` and to stop vnc use the command ```vncstop```

To enter the Debian proot install from terminal use the command ```debian```

Also note, you do not need to set display in Debian proot as it is already set. This means you can use the terminal to start any GUI application and it will startup.

&nbsp;

# Hardware Acceleration & Proot

This is setup with virglrenderer-android installed for hardware acceleration on supported devices. Use the command ```virgl app_name_here``` to run that app with hardware acceleration. This should also work in proot. To enter proot use the command ```debian```, from there you can install aditional software. 

&nbsp;

There are two scripts available for this setup as well
  
```prun```  Running this followed by a command you want to run from the debian proot install will allow you to run stuff from the termux terminal without running ```debian``` to get into the proot itself.
  
```cp2menu``` Running this will pop up a window allowing you to copy .desktop files from debian proot into the termux xfce "start" menu so you won't need to launch them from terminal. A launcher is available in the System menu section.

&nbsp;

# Install

To install run this command in termux

```
curl -sL https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/setup.sh -o setup.sh && chmod +x setup.sh && ./setup.sh
```

&nbsp;

# Problem Termux Process completed (signal 9) - press Enter

read https://docs.andronix.app/android-12/andronix-on-android-12-and-beyond

or

To fix this issue follow along with this video https://www.youtube.com/watch?v=mjXSh3yq-I0

  


&nbsp;

# Screenshot
![Desktop Screenshot](desktop.png)
