##
## Plug-in for installing Gentoo Linux.
##

DISTRO_NAME="Gentoo Linux"

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

	case "$DISTRO_ARCH" in
		aarch64)
			rootfs="$(curl --silent http://distfiles.gentoo.org/releases/arm64/autobuilds/latest-stage3-arm64.txt | grep tar | awk '{print $1}')"
			url="http://distfiles.gentoo.org/releases/arm64/autobuilds/${rootfs}"
			;;
		armv7l|armv8l)
			rootfs="$(curl --silent http://distfiles.gentoo.org/releases/arm/autobuilds/latest-stage3-armv7a.txt | grep tar | awk '{print $1}')"
			url="http://distfiles.gentoo.org/releases/arm/autobuilds/${rootfs}"
			;;
		i686)
			rootfs="$(curl --silent http://distfiles.gentoo.org/releases/x86/autobuilds/latest-stage3-i686.txt | grep tar | awk '{print $1}')"
			url="http://distfiles.gentoo.org/releases/x86/autobuilds/${rootfs}"
			;;
		x86_64)
			rootfs="$(curl --silent http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64.txt | grep tar | awk '{print $1}')"
			url="http://distfiles.gentoo.org/releases/amd64/autobuilds/${rootfs}"
			;;
	esac

	echo "${url}"
}

# Define here additional steps which should be executed
# for configuration.
distro_setup() {
	# Hint: $PWD is the distribution rootfs directory.
	#echo "hello world" > ./etc/motd

	# Run command within proot'ed environment with
	# run_proot_cmd function.
	# Uncomment this to run 'emerge --ask --verbose --update --deep --changed-use @world' during installation.
	#run_proot_cmd emerge --ask --verbose --update --deep --changed-use @world
	:
}
