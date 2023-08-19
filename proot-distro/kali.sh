# This is a default distribution plug-in.
# Do not modify this file as your changes will be overwritten on next update.
# If you want customize installation, please make a copy.

DISTRO_NAME="Kali Linux (nethunter)"

TARBALL_URL['aarch64']="https://kali.download/nethunter-images/current/rootfs/kalifs-arm64-minimal.tar.xz"
TARBALL_SHA256['aarch64']="7e17a35e1528a5efc12bf1bbad00a764d38a5724e2b08a226849c594a3b3f029"
TARBALL_URL['arm']="https://kali.download/nethunter-images/current/rootfs/kalifs-armhf-minimal.tar.xz"
TARBALL_SHA256['arm']="62f07cd260cd31e9a84c25a331f3db0278d9ccdeb648522b69382946acdd8581"
TARBALL_URL['i686']="https://kali.download/nethunter-images/current/rootfs/kalifs-i386-minimal.tar.xz"
TARBALL_SHA256['i686']="e83cd8f57d6128efd64e88b191a1653ff315fffd78c05d536d2b6f63b2e6d49d"
TARBALL_URL['x86_64']="https://kali.download/nethunter-images/current/rootfs/kalifs-amd64-minimal.tar.xz"
TARBALL_SHA256['x86_64']="096290b7229ab81f1ac3b35324a7109dc19f1e2f5bf6aab1ff8254ebc95463ea"

# This function defines any additional steps that should be executed during
# installation. You can use "run_proot_cmd" to execute a given command in
# proot environment.
distro_setup() {
	run_proot_cmd rm -rf /var/lib/dpkg/info/postgresql* && dpkg --configure -a && apt update && apt upgrade 
}