##
## Plug-in for installing Artix Linux.
##


DISTRO_NAME="Artix Linux (runit)"

# You can override a CPU architecture to let distribution
# be executed by QEMU (user-mode).
#
# You can specify the following values here:
#
#  * aarch64: AArch64 (ARM64, 64bit ARM)
#  * armv7l:  ARM (32bit)
#  * i686:    x86 (32bit)
#  * x86_64:  x86 (64bit)
#
# Default value is set by proot-distro script and is equal
# to the CPU architecture of your device (uname -m).
#DISTRO_ARCH=$(uname -m)

# Returns download URL and SHA-256 of file in this format:
# SHA-256|FILE-NAME
get_download_url() {
	local rootfs
	local sha256

	# Currently Running artix on proot-distro needs aarch64 at the moment
	# You may try it by specifying DISTRO_ARCH to activate QEMU Emulation
	case "$DISTRO_ARCH" in
		aarch64)
			FILENAME="$(curl --silent --fail https://armtix.artixlinux.org/images/sha256sums | grep runit | awk '{print $2}')"
			rootfs="https://armtix.artixlinux.org/images/${FILENAME}"
			;;
	esac

	echo "${rootfs}"
}

# Define here additional steps which should be executed
# for configuration.
distro_setup() {
	# Pacman keyring initialization.
	run_proot_cmd pacman-key --init
	run_proot_cmd pacman-key --populate archlinuxarm artix

	# Initialize en_US locale.
	echo "en_US.UTF-8 UTF-8" > ./etc/locale.gen
	run_proot_cmd locale-gen
	sed -i 's/LANG=C.UTF-8/LANG=en_US.UTF-8/' ./etc/profile.d/termux-proot.sh

	# Uninstall packages which are not necessary.
	run_proot_cmd pacman -Rnsc --noconfirm linux-aarch64

	# Ask a user to perform system update
	read -p "Do you wish to perform Artix system update? [Y/n] " yn
		case "${yn}" in
			Y*|y*)
				run_proot_cmd pacman -Syyu --noconfirm
				;;
			*) ;;
		esac
	:
}
