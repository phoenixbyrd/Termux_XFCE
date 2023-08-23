# Termux_XFCE

Sets up a termux XFCE desktop and a Debian proot install.

You only need to pick your username and follow the prompts. This will take roughly 3GB of storage space. Please note, this can be a lengthy process.

This setup uses Termux-X11, the termux-x11 server will be installed and you will be prompted to allow termux to install the Android APK.

This is is how I personally use Termux on my Galaxy Fold 3, script was created mainly for personal use but also for others if they wanted to try out my setup. This is my daily driver used with a 15 inch Lepow portable monitor and bluetooth keyboard and mouse.

&nbsp;

# Starting the desktop

During install you will recieve a popup to allow installs from termux, this will open the APK for the Termux-X11 android app. While you do not have to allow installs from termux, you will still need to install manually by using a file browser and finding the APK in your downloads folder. 
  
Use the command ```start``` to initiate a Termux-X11 session
  
This will start the termux-x11 server, XFCE4 desktop and open the Termux-X11 app right into the desktop. 

To enter the Debian proot install from terminal use the command ```debian```

Also note, you do not need to set display in Debian proot as it is already set. This means you can use the terminal to start any GUI application and it will startup.

&nbsp;

# Hardware Acceleration & Proot

This is setup with virglrenderer-android installed for hardware acceleration on supported devices. Termux XFCE desktop and apps install in termux are automatically hardware accelerated. Apps install in proot are not, se the command ```virgl app_name_here``` to run that app with hardware acceleration in debian proot. Some apps might require the use of ```MESA_GL_VERSION_OVERRIDE=4.0```
  
The full hardware acceleration command would be ```GALLIUM_DRIVER=virvpipe MESA_GL_VERSION_OVERRIDE=4.0``` for reference.   
    
To enter proot use the command ```debian```, from there you can install aditional software with apt and use cp2menu in termux to copy the menu items over to termux xfce menu. 

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

# Process completed (signal 9) - press Enter

install LADB from playstore, connect to wifi or from here https://github.com/hyperio546/ladb-builds/releases
  
In split screen have one side LADB and the other side showing developer settings.
  
In developer settings, enable wireless debugging then click into there to get the port number then click pair device to get the pairing code.
  
Enter both those values into LADB
  
Once it connects run this command
  
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"

  


&nbsp;

![Desktop Screenshot](desktop.png)
