#!/bin/bash

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

# Log file for debugging
LOG_FILE="$HOME/termux_setup.log"
exec 2>>"$LOG_FILE"

# Temporary directory for setup
TEMP_DIR=$(mktemp -d)

finish() {
    local ret=$?
    if [ $ret -ne 0 ] && [ $ret -ne 130 ]; then
        echo "ERROR: An issue occurred. Please check $LOG_FILE for details."
    fi
    rm -rf "$TEMP_DIR"
}

trap finish EXIT

# Ensure the script is running in Termux
if [[ $(uname -o) != "Android" ]]; then
    echo "This script is intended for Termux on Android only. Exiting."
    exit 1
fi

clear

# Confirm action
read -p "This will modify your Termux environment. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Setup aborted by user."
    exit 0
fi

# Change repository
if ! termux-change-repo; then
    echo "Failed to change repository. Exiting."
    exit 1
fi

# Upgrade packages
if ! pkg upgrade -y -o Dpkg::Options::="--force-confold"; then
    echo "Failed to upgrade packages. Exiting."
    exit 1
fi

# Update termux.properties
if [ -f "$HOME/.termux/termux.properties" ]; then
    sed -i '12s/^#//' $HOME/.termux/termux.properties
else
    echo "Warning: termux.properties file not found. Skipping update."
fi

# Display a message
clear
echo "\nSetting up Termux Storage access.\n"
read -n 1 -s -r -p "Press any key to continue..."
if ! termux-setup-storage; then
    echo "Failed to set up Termux storage. Exiting."
    exit 1
fi

# Install core dependencies
dependencies=('wget' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio' 'git')
missing_deps=()
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
    fi
done

if [ "${#missing_deps[@]}" -gt 0 ]; then
    if ! pkg install -y "${missing_deps[@]}" -o Dpkg::Options::="--force-confold"; then
        echo "Failed to install missing dependencies: ${missing_deps[*]}. Exiting."
        exit 1
    fi
fi

# Create default directories
mkdir -p "$HOME/Desktop" "$HOME/Downloads"

# Install XFCE desktop environment
xfce_packages=('xfce4' 'xfce4-goodies' 'xfce4-pulseaudio-plugin' 'firefox' 'termux-x11-nightly' 'virglrenderer-android')
if ! pkg install -y "${xfce_packages[@]}" -o Dpkg::Options::="--force-confold"; then
    echo "Failed to install XFCE packages. Exiting."
    exit 1
fi

# Create start script
cat <<'EOF' > $PREFIX/bin/start
#!/bin/bash

# Kill open X11 processes
kill -9 $(pgrep -f "termux.x11") 2>/dev/null

# Get the phone manufacturer
MANUFACTURER=$(getprop ro.product.manufacturer | tr '[:upper:]' '[:lower:]')

# Check the manufacturer
if [[ "$MANUFACTURER" == "samsung" ]]; then
    [ -d ~/.config/pulse ] && rm -rf ~/.config/pulse
    LD_PRELOAD=/system/lib64/libskcodec.so pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
else
   pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
fi

# Set audio server
export PULSE_SERVER=127.0.0.1

# Prepare termux-x11 session
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null &

# Wait a bit until termux-x11 gets started.
sleep 3

# Launch Termux X11 main activity
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# Function to check the GPU type
gpu_check() {
    # Attempt to detect GPU using getprop
    gpu_egl=$(getprop ro.hardware.egl)
    gpu_vulkan=$(getprop ro.hardware.vulkan)

    # Combine unique GPU information
    detected_gpu="$(echo -e "$gpu_egl\n$gpu_vulkan" | sort -u | tr '\n' ' ' | sed 's/ $//')"

    if echo "$detected_gpu" | grep -iq "adreno"; then
        echo "GPU detected: $detected_gpu"
        MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 LIBGL_DRI3_DISABLE=1 virgl_test_server_android & > /dev/null 2>&1
    elif echo "$detected_gpu" | grep -iq "mali"; then
        echo "GPU detected: $detected_gpu"
        MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 LIBGL_DRI3_DISABLE=1 virgl_test_server_android --angle-gl & > /dev/null 2>&1
    else
        echo "Unknown GPU type detected: $detected_gpu"
        exit 1
    fi
}

# Run the GPU check function
gpu_check

# Run XFCE4 Desktop
dbus-daemon --session --address=unix:path=$PREFIX/var/run/dbus-session &
env DISPLAY=:0 GALLIUM_DRIVER=virpipe dbus-launch --exit-with-session xfce4-session & > /dev/null 2>&1

exit 0
EOF

chmod +x $PREFIX/bin/start

# Create shutdown utility
cat <<'EOF' > $PREFIX/bin/kill_termux_x11
#!/bin/bash

# Send stop action to Termux X11
am broadcast -a com.termux.x11.ACTION_STOP -p com.termux.x11 > /dev/null 2>&1

# Kill dependent processes
pkill -f "virgl_test_server_android" 2>/dev/null || echo "No VirGL process found."
pkill -f "xfce4-session" 2>/dev/null || echo "No XFCE4 session found."
pkill -f "com.termux" 2>/dev/null || echo "No Termux processes found."
EOF

chmod +x $PREFIX/bin/kill_termux_x11

# Create kill_termux_x11.desktop
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
cp $HOME/Desktop/kill_termux_x11.desktop $PREFIX/share/applications
