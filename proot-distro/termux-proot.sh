#/usr/bin/env sh

# termux-proot - A sandboxed, 2nd termux, isolated or jailed termux environment with proot
# https://git.io/termux-proot

[ -z $TERMUX_SANDBOX_PATH ] && export TERMUX_SANDBOX_PATH=$PREFIX/../../sandbox 
[ -z $TERMUX_SANDBOX_APPPATH ] && export TERMUX_SANDBOX_APPPATH=/data/data/com.termux/files
[ "$(id -u)" = "0" ] && exec echo -e "You shouldn't execute this script as root, don't you?\nSo you're trying to harm your own Device.\n\nAbility to use termux-proot with root (even fake) is disabled permanently.\nJust do it in your real termux, Or use chroot. But don't blame me for broken device OK?"

# { Installation }
[ $(uname -o) != "Android" ] && exec echo "Sorry. This script is only executeable on Android. Use Termux to exexute this or use termux-docker."
! [ -d $TERMUX_SANDBOX_PATH ] || [ -z "$(ls -A $TERMUX_SANDBOX_PATH)" ] && {
	! [ -f ${TMPDIR:-/tmp}/.termux-rootfs.zip ] && echo "[#  ] Downloading Latest Termux Bootstrap...." && curl -#Lo ${TMPDIR:-/tmp}/.termux-rootfs.zip https://github.com/termux/termux-packages/releases/download/$(curl -s "https://api.github.com/repos/termux/termux-packages/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')/bootstrap-$(dpkg --print-architecture).zip
	mkdir $TERMUX_SANDBOX_PATH && cd $TERMUX_SANDBOX_PATH

	echo -n "[## ] Extracting.... "
	unzip -q ${TMPDIR:-/tmp}/.termux-rootfs.zip

	[ $? != 0 ] && echo Fail && proot -0 rm -rf $TERMUX_SANDBOX_PATH && exit 6
	echo Done

	echo -n "[###] Symlinking.... "
	while read p; do
		ln -s ${p/←/ }
	done <SYMLINKS.txt && rm SYMLINKS.txt
	echo Done
}

ARGS=proot
ARGS="$ARGS --kill-on-exit -r $TERMUX_SANDBOX_PATH $TERMUX_SANDBOX_PROOT_OPTIONS"

# Make sure that some common directory like /home is there.
# Otherwise, we recreate the directory
for dir in $TERMUX_SANDBOX_PATH/var/cache $TERMUX_SANDBOX_PATH/home $TERMUX_SANDBOX_PATH/sdcard; do
	! [ -d $dir ] && mkdir $dir
done

# Bind some common path
for bind in /dev /proc /sys /system /vendor /apex /linkerconfig/ld.config.txt /property_context $TERMUX_SANDBOX_PATH:$TERMUX_SANDBOX_APPPATH/usr $TERMUX_SANDBOX_PATH/var/cache:/data/data/com.termux/cache $TERMUX_SANDBOX_PATH/home:$TERMUX_SANDBOX_APPPATH/home; do
	[ -d $bind ] || [ -f $bind ] || echo $bind | grep com.termux > /dev/null && ARGS="$ARGS -b $bind"
done

ARGS="$ARGS -w $TERMUX_SANDBOX_APPPATH/home"
ARGS="$ARGS $TERMUX_SANDBOX_APPPATH/usr/bin/env -i"
ARGS="$ARGS HOME=$TERMUX_SANDBOX_APPPATH/home"
ARGS="$ARGS PATH=$TERMUX_SANDBOX_APPPATH/usr/bin"
ARGS="$ARGS TERM=${TERM:-xterm-256color}"
ARGS="$ARGS COLORTERM=${COLORTERM:-truecolor}"
ARGS="$ARGS ANDROID_DATA=/data"
ARGS="$ARGS ANDROID_ROOT=/system"
ARGS="$ARGS EXTERNAL_STORAGE=/sdcard"
ARGS="$ARGS LANG=${LANG:-en_US.UTF-8}"
ARGS="$ARGS LD_LIBRARY_PATH=$TERMUX_SANDBOX_APPPATH/usr/lib"
[ -x $TERMUX_SANDBOX_APPPATH/usr/lib/libtermux-exec.so ] && ARGS="$ARGS LD_PRELOAD=$TERMUX_SANDBOX_APPPATH/usr/lib/libtermux-exec.so"
ARGS="$ARGS TERMUX_VERSION=${TERMUX_VERSION:-0.118}"
ARGS="$ARGS PREFIX=$TERMUX_SANDBOX_APPPATH/usr"
ARGS="$ARGS TMPDIR=$TERMUX_SANDBOX_APPPATH/usr/tmp"
ARGS="$ARGS $TERMUX_SANDBOX_ENV"

cmd="$@"

# Unset Preload Library.
unset LD_PRELOAD

[ -z "$cmd" ] && exec $ARGS /bin/login
! [ -z "$cmd" ] && exec $ARGS /bin/login -c "$cmd"
