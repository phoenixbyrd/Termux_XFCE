#!/bin/bash

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file for debugging
LOG_FILE="$HOME/termux_setup.log"
exec 2>>"$LOG_FILE"

# Temporary directory for setup
TEMP_DIR=$(mktemp -d)

# Function to print colored status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "ok" ]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [ "$status" = "warn" ]; then
        echo -e "${YELLOW}!${NC} $message"
    else
        echo -e "${RED}✗${NC} $message"
    fi
}

# Function to clean up on exit
finish() {
    local ret=$?
    if [ $ret -ne 0 ] && [ $ret -ne 130 ]; then
        echo -e "${RED}ERROR: An issue occurred. Please check $LOG_FILE for details.${NC}"
    fi
    rm -rf "$TEMP_DIR"
}

trap finish EXIT

# Function to detect system compatibility
detect_termux() {
    local errors=0
    
    echo -e "\n${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      System Compatibility Check    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}\n"
    
    # Check if running on Android
    if [[ "$(uname -o)" = "Android" ]]; then
        print_status "ok" "Running on Android $(getprop ro.build.version.release)"
    else
        print_status "error" "Not running on Android"
        ((errors++))
    fi

    # Check architecture
    local arch=$(uname -m)
    if [[ "$arch" = "aarch64" ]]; then
        print_status "ok" "Architecture: $arch"
    else
        print_status "error" "Unsupported architecture: $arch (requires aarch64)"
        ((errors++))
    fi

    # Check for required directories
    if [[ -d "$PREFIX" ]]; then
        print_status "ok" "Termux PREFIX directory found"
    else
        print_status "error" "Termux PREFIX directory not found"
        ((errors++))
    fi

    # Check available storage space
    local free_space=$(df -h "$HOME" | awk 'NR==2 {print $4}')
    if [[ $(df "$HOME" | awk 'NR==2 {print $4}') -gt 4194304 ]]; then
        print_status "ok" "Available storage: $free_space"
    else
        print_status "warn" "Low storage space: $free_space (4GB recommended)"
    fi

    # Check RAM
    local total_ram=$(free -m | awk 'NR==2 {print $2}')
    if [[ $total_ram -gt 2048 ]]; then
        print_status "ok" "RAM: ${total_ram}MB"
    else
        print_status "warn" "Low RAM: ${total_ram}MB (2GB recommended)"
    fi

    echo
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}All system requirements met!${NC}"
        return 0
    else
        echo -e "${RED}Found $errors error(s). System requirements not met.${NC}"
        return 1
    fi
}

# Main installation function
main() {
    clear
    echo -e "\n${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    XFCE Desktop Installation       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"

    # Check system compatibility
    if ! detect_termux; then
        echo -e "${YELLOW}Please ensure your system meets the following requirements:${NC}"
        echo "• Termux GitHub release"
        echo "• ARM64 (aarch64) device"
        echo "• Android operating system"
        echo "• At least 4GB free storage"
        echo "• At least 2GB RAM recommended"
        exit 1
    fi

    echo -e "${GREEN}System check passed. Ready to proceed with installation.${NC}"
    echo -e "${GREEN}This will install XFCE native desktop in Termux"
    echo -e "${GREEN}A Debian proot-distro is also installed for additional software"
    echo -e "${GREEN}while also enabling hardware acceleration"
    echo -e "${GREEN}This setup has been tested on a Samsung Galaxy S24 Ultra"
    echo -e "${GREEN}It should run on most phones however.${NC}"
    echo -e "\n${YELLOW}Press Enter to continue or Ctrl+C to cancel${NC}"
    
    read -r

    # Continue with your existing installation code here
    echo -n "Please enter username for proot installation: " > /dev/tty
    read username < /dev/tty

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

# Setup Termux Storage Access 
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
mkdir -p "$HOME/Desktop" "$HOME/Downloads" "$HOME/.fonts"

# Install XFCE desktop environment
xfce_packages=('xfce4' 'xfce4-goodies' 'xfce4-pulseaudio-plugin' 'firefox' 'starship' 'termux-x11-nightly' 'virglrenderer-android' 'papirus-icon-theme' 'eza' 'bat' 'arc-gtk-theme')
if ! pkg install -y "${xfce_packages[@]}" -o Dpkg::Options::="--force-confold"; then
    echo "Failed to install XFCE packages. Exiting."
    exit 1
fi

# Set aliases
echo "
alias debian='proot-distro login debian --user $username --shared-tmp'
alias ls='eza -lF --icons'
alias cat='bat '

#eval "$(starship init bash)"
" >> $PREFIX/etc/bash.bashrc

# Download starship theme
#curl -o ~/.config/starship.toml https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/refs/heads/main/starship.toml

# Download Wallpaper
wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/dark_waves.png
mv dark_waves.png $PREFIX/share/backgrounds/xfce/

# Install Fluent Cursor Icon Theme
wget https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/tags/2023-02-01.zip
unzip 2023-02-01.zip
mv Fluent-icon-theme-2023-02-01/cursors/dist $PREFIX/share/icons/ 
mv Fluent-icon-theme-2023-02-01/cursors/dist-dark $PREFIX/share/icons/
rm -rf $HOME//Fluent*
rm 2023-02-01.zip

# Setup Fonts
wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
unzip CascadiaCode-2111.01.zip
mv otf/static/* .fonts/ && rm -rf otf
mv ttf/* .fonts/ && rm -rf ttf/
rm -rf woff2/ && rm -rf CascadiaCode-2111.01.zip

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip
unzip Meslo.zip
mv *.ttf .fonts/
rm Meslo.zip
rm LICENSE.txt
rm readme.md

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/NotoColorEmoji-Regular.ttf
mv NotoColorEmoji-Regular.ttf .fonts

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/font.ttf
mv font.ttf .termux/font.ttf

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

# Kill Termux-X11
am broadcast -a com.termux.x11.ACTION_STOP -p com.termux.x11 > /dev/null 2>&1

# Kill Termux
pkill -f termux

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

# Create prun script
cat <<'EOF' > $PREFIX/bin/prun
#!/bin/bash
varname=$(basename $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/*)
pd login debian --user $varname --shared-tmp -- env DISPLAY=:0 $@

EOF
chmod +x $PREFIX/bin/prun

# Create zrun script
cat <<'EOF' > $PREFIX/bin/zrun
#!/bin/bash
varname=$(basename $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/*)
pd login debian --user $varname --shared-tmp -- env DISPLAY=:0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform $@

EOF
chmod +x $PREFIX/bin/zrun

# Create zrunhud script
cat <<'EOF' > $PREFIX/bin/zrunhud
#!/bin/bash
varname=$(basename $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/*)
pd login debian --user $varname --shared-tmp -- env DISPLAY=:0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform GALLIUM_HUD=fps $@

EOF
chmod +x $PREFIX/bin/zrunhud

# Install Debian proot
pkgs_proot=('sudo' 'onboard')

# Install Debian proot
pd install debian
pd login debian --shared-tmp -- env DISPLAY=:0 apt update
pd login debian --shared-tmp -- env DISPLAY=:0 apt upgrade -y
pd login debian --shared-tmp -- env DISPLAY=:0 apt install "${pkgs_proot[@]}" -y -o Dpkg::Options::="--force-confold"

# Create user
pd login debian --shared-tmp -- env DISPLAY=:0 groupadd storage
pd login debian --shared-tmp -- env DISPLAY=:0 groupadd wheel
pd login debian --shared-tmp -- env DISPLAY=:0 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"

# Add user to sudoers
chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w  $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

# Set proot DISPLAY
echo "export DISPLAY=:0" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Set aliases
echo "
alias ls='eza -lF --icons'
alias cat='bat '

#eval "$(starship init bash)"
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Set proot timezone
timezone=$(getprop persist.sys.timezone)
pd login debian --shared-tmp -- env DISPLAY=:0 rm /etc/localtime
pd login debian --shared-tmp -- env DISPLAY=:0 cp /usr/share/zoneinfo/$timezone /etc/localtime

# Setup Hardware Acceleration in proot
pd login debian --shared-tmp -- env DISPLAY=:0 wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
pd login debian --shared-tmp -- env DISPLAY=:0 sudo apt install -y ./mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb

# Download proot starship theme
#curl -o $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config/starship.toml https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/refs/heads/main/starship_proot.toml

}

# Start installation
main

#source .bashrc
#termux-reload-settings
