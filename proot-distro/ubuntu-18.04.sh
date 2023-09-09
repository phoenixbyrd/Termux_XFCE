# Ubuntu Bionic for proot-distro 2.0
DISTRO_NAME="Ubuntu (bionic)"

TARBALL_URL['aarch64']="https://github.com/termux/proot-distro/releases/download/v1.9.0-updated-distributions/bionic-server-cloudimg-arm64-root.tar.xz"
TARBALL_SHA256['aarch64']="1f9ea68be35cc646017c0da6f1001bb0613bd7c540617aee8e9fd0d30e80078c"
TARBALL_URL['arm']="https://github.com/termux/proot-distro/releases/download/v1.9.0-updated-distributions/bionic-server-cloudimg-armhf-root.tar.xz"
TARBALL_SHA256['arm']="ce9533c6920f621e23f4e379a2f7c92568807187ac88e93cbd53f9ecee2d7899"
TARBALL_URL['x86_64']="https://github.com/termux/proot-distro/releases/download/v1.9.0-updated-distributions/bionic-server-cloudimg-amd64-root.tar.xz"
TARBALL_SHA256['x86_64']="e16108fd926cd170bc5de2797a66da99f3b10afd9706384c02ef3806297d17fc"
TARBALL_URL['i686']="https://github.com/termux/proot-distro/releases/download/v1.9.0-updated-distributions/bionic-server-cloudimg-i386-root.tar.xz"
TARBALL_SHA256['i686']="55af22f3b181de25b9142f308713b8034b2851990ac0b30eabaeb9ccded4bc15"

TARBALL_STRIP_OPT=0

distro_setup() {
    # Nothing to do here
    :
}
