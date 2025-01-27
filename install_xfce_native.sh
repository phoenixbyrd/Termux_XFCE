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
        echo -e "${YELLOW}All system requirements met!${NC}"
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

    echo -e "\n${GREEN}This will install XFCE native desktop in Termux"
    echo -e "${GREEN}A Debian proot-distro is also installed for additional software"
    echo -e "${GREEN}while also enabling hardware acceleration"
    echo -e "${GREEN}This setup has been tested on a Samsung Galaxy S24 Ultra"
    echo -e "${GREEN}It should run on most phones however.${NC}"
    echo -e "\n${RED}Please install termux-x11: ${YELLOW}https://github.com/termux/termux-x11/releases"
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

# Check if storage access is already granted
if [ -d ~/storage ]; then
    echo "Storage access is already granted"
else
    # Setup Termux Storage Access only if not already granted
    if ! termux-setup-storage; then
        echo "Failed to set up Termux storage. Exiting."
        echo "${YELLOW}Please clear termux data in app info setting and run setup again${NC}"
        exit 1
    fi
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
mkdir -p "$HOME/Desktop" "$HOME/Downloads" "$HOME/.fonts" "$HOME/.config" "$HOME/.config/autostart/" "$HOME/.config/gtk-3.0/"
#ln -s /storage/emulated/0/Music $HOME/Music
#ln -s /storage/emulated/0/Pictures $HOME/Pictures

# Install XFCE desktop environment
xfce_packages=('xfce4' 'xfce4-goodies' 'xfce4-pulseaudio-plugin' 'firefox' 'starship' 'termux-x11-nightly' 'virglrenderer-android' 'fastfetch' 'papirus-icon-theme' 'eza' 'bat')
if ! pkg install -y "${xfce_packages[@]}" -o Dpkg::Options::="--force-confold"; then
    echo "Failed to install XFCE packages. Exiting."
    exit 1
fi

# Set aliases
echo "
alias debian='proot-distro login debian --user $username --shared-tmp'
alias ls='eza -lF --icons'
alias cat='bat '

eval "$(starship init bash)"
" >> $PREFIX/etc/bash.bashrc

# Download starship theme
curl -o $HOME/.config/starship.toml https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/refs/heads/main/starship.toml
sed -i "s/phoenixbyrd/$username/" $HOME/.config/starship.toml

# Download Wallpaper
wget https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/main/dark_waves.png
mv dark_waves.png $PREFIX/share/backgrounds/xfce/

# Create bookmarks with custom name
cat <<EOF > $HOME/.config/gtk-3.0/bookmarks
file:////data/data/com.termux/files/home/Downloads
file:///data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian/home/$username Debian Home
file:////data/data/com.termux/files/home/storage/shared/ Android Storage
EOF

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

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Create start script
cat <<'EOF' > $PREFIX/bin/start
#!/bin/bash

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

# Configuration
PULSE_SERVER="127.0.0.1"
DISPLAY=":0"
XDG_RUNTIME_DIR="${TMPDIR}"
SLEEP_SHORT=1
ENABLE_VIRGL=true # Default to enabling VirGL

# Logging levels
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_info() {
    log "[INFO] $1"
}

log_warn() {
    log "[WARN] $1"
}

log_error() {
    log "[ERROR] $1"
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to kill processes safely
kill_processes() {
    local processes=("$@")
    for process in "${processes[@]}"; do
        pkill -f "$process" || true
    done
}

# Function to check if the device is a Samsung device
is_samsung_device() {
    local manufacturer
    manufacturer=$(getprop ro.product.manufacturer | tr '[:upper:]' '[:lower:]')
    if [[ "$manufacturer" == "samsung" ]]; then
        return 0
    else
        return 1
    fi
}

# Display usage information
usage() {
    echo "Usage: $0 [--no-virgl] [--help]"
    echo "Start XFCE4 desktop environment on Termux with optional hardware acceleration."
    echo "  --no-virgl    Disable VirGL (hardware acceleration)."
    echo "  --help        Display this help message."
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-virgl)
            ENABLE_VIRGL=false
            shift
            ;;
        --help)
            usage
            ;;
        *)
            log_error "Unknown argument: $1"
            ;;
    esac
done

# Validate environment and dependencies
if ! command_exists termux-x11; then
    log_error "This script is intended to run in Termux. Exiting..."
fi

for cmd in pulseaudio termux-x11 dbus-daemon xfce4-session; do
    if ! command_exists "$cmd"; then
        log_error "Required command '$cmd' not found. Exiting..."
    fi
done

# Kill existing processes
log_info "Killing existing processes..."
kill_processes "termux.x11" "xfce4-session" "virgl_test_server_android"

# Start PulseAudio
log_info "Starting PulseAudio..."
pulseaudio --kill >/dev/null 2>&1 || true

# Check if the device is a Samsung device
if is_samsung_device; then
    log_info "Detected Samsung device. Applying Samsung-specific PulseAudio settings..."
    [ -d ~/.config/pulse ] && rm -rf ~/.config/pulse
    LD_PRELOAD=/system/lib64/libskcodec.so pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 >/dev/null 2>&1
else
    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 >/dev/null 2>&1
fi

export PULSE_SERVER

# Start Termux-X11 server
log_info "Starting Termux-X11 server..."
termux-x11 "$DISPLAY" -ac >/dev/null 2>&1 &
sleep "$SLEEP_SHORT"

# Launch Termux-X11 app
log_info "Launching Termux-X11 app..."
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep "$SLEEP_SHORT"

# Start VirGL server (if enabled)
if $ENABLE_VIRGL; then
    log_info "Starting VirGL server for hardware acceleration..."
    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 virgl_test_server_android --angle-gl >/dev/null 2>&1 &
    sleep "$SLEEP_SHORT"

    # Detect and configure GPU
    detect_gpu() {
        local gpu_info
        gpu_info=$(dmesg | grep -i -e "adreno" -e "mali" -e "powervr" -e "lima" || true)

        if echo "$gpu_info" | grep -qi "adreno"; then
            log_info "Detected Adreno GPU. Enabling Adreno-specific optimizations..."
            export GALLIUM_DRIVER=virpipe
            export MESA_LOADER_DRIVER_OVERRIDE=zink
        elif echo "$gpu_info" | grep -qi "mali"; then
            log_info "Detected Mali GPU. Enabling Mali-specific optimizations..."
            export GALLIUM_DRIVER=lima
            export MESA_LOADER_DRIVER_OVERRIDE=lima
        elif echo "$gpu_info" | grep -qi "powervr"; then
            log_info "Detected PowerVR GPU. Enabling PowerVR-specific optimizations..."
            export GALLIUM_DRIVER=virpipe
            export MESA_LOADER_DRIVER_OVERRIDE=zink
        else
            log_warn "No specific GPU detected. Using default VirGL driver."
            export GALLIUM_DRIVER=virpipe
        fi
    }

    detect_gpu
else
    log_info "VirGL (hardware acceleration) is disabled."
    export GALLIUM_DRIVER=swrast # Use software rendering
fi

# Start XFCE4 session
log_info "Starting XFCE4 session..."
dbus-daemon --session --address=unix:path=$PREFIX/var/run/dbus-session >/dev/null 2>&1 &
sleep "$SLEEP_SHORT"
env DISPLAY="$DISPLAY" GALLIUM_DRIVER="$GALLIUM_DRIVER" dbus-launch --exit-with-session xfce4-session >/dev/null 2>&1 &

log_info "XFCE4 desktop environment started successfully!"
echo "You can now use your XFCE4 desktop on Termux."
echo "To exit, use the 'kill_termux_x11' command in terminal or use the kill_termux_x11 icon on the desktop."

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
mv $HOME/Desktop/kill_termux_x11.desktop $PREFIX/share/applications

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

# App Installer

git clone https://github.com/phoenixbyrd/App-Installer.git $HOME/.config/App-Installer
chmod +x $HOME/.config/App-Installer/*

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=App Installer
Comment=
Exec=/data/data/com.termux/files/home/.config/App-Installer/app-installer
Icon=package-install
Categories=System;
Path=
Terminal=false
StartupNotify=false
" > $HOME/Desktop/App-Installer.desktop
chmod +x $HOME/Desktop/App-Installer.desktop
cp $HOME/Desktop/App-Installer.desktop $PREFIX/share/applications

# cp2menu

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/refs/heads/main/cp2menu -O $PREFIX/bin/cp2menu
chmod +x $PREFIX/bin/cp2menu

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=cp2menu
Comment=
Exec=cp2menu
Icon=edit-move
Categories=System;
Path=
Terminal=false
StartupNotify=false
" > $PREFIX/share/applications/cp2menu.desktop
chmod +x $PREFIX/share/applications/cp2menu.desktop

# Install Debian proot
pkgs_proot=('sudo' 'onboard' 'conky-all' 'flameshot')

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

eval "$(starship init bash)"
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Set proot timezone
timezone=$(getprop persist.sys.timezone)
pd login debian --shared-tmp -- env DISPLAY=:0 rm /etc/localtime
pd login debian --shared-tmp -- env DISPLAY=:0 cp /usr/share/zoneinfo/$timezone /etc/localtime

# Setup Hardware Acceleration in proot
pd login debian --shared-tmp -- env DISPLAY=:0 wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
pd login debian --shared-tmp -- env DISPLAY=:0 sudo apt install -y ./mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb

mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config/

# Download proot starship theme
curl -o $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config/starship.toml https://raw.githubusercontent.com/phoenixbyrd/Termux_XFCE/refs/heads/main/starship_proot.toml
sed -i "s/phoenixbyrd/$username/" $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config/starship.toml

wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/conky.tar.gz
tar -xvzf conky.tar.gz
rm conky.tar.gz
mv $HOME/.config/conky/ $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.config/

# Conky
cp $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/conky.desktop $HOME/.config/autostart/
sed -i 's|^Exec=.*$|Exec=prun conky -c .config/conky/Alterf/Alterf.conf|' $HOME/.config/autostart/conky.desktop

# Flameshot
cp $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/org.flameshot.Flameshot.desktop $HOME/.config/autostart/
sed -i 's|^Exec=.*$|Exec=prun flameshot|' $HOME/.config/autostart/org.flameshot.Flameshot.desktop

chmod +x $HOME/.config/autostart/*.desktop

}

# Start installation
main

clear
# Display usage instructions
echo -e "\n${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Setup Complete!            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}Available Commands:${NC}"
echo -e "${YELLOW}start${NC}"
echo -e "Launches the XFCE desktop environment with hardware acceleration enabled\n"

echo -e "${YELLOW}debian${NC}"
echo -e "Enters the Debian proot environment for installing additional aarch64 packages\n"

echo -e "${YELLOW}prun${NC}"
echo -e "Executes Debian proot applications directly from Termux\n"

echo -e "${YELLOW}zrun${NC}"
echo -e "Runs Debian applications with hardware acceleration enabled\n"

echo -e "${YELLOW}zrunhud${NC}"
echo -e "Same as zrun but includes an FPS overlay for performance monitoring\n"

echo -e "${GREEN}Note:${NC} For Firefox hardware acceleration:"
echo -e "1. Open Firefox settings"
echo -e "2. Search for 'performance'"
echo -e "3. Uncheck the hardware acceleration option\n"

echo -e "${YELLOW}Installation complete! Use 'start' to launch your desktop environment.${NC}\n"


source $PREFIX/etc/bash.bashrc
termux-reload-settings
rm install.sh
