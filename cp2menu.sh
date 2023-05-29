#!/bin/bash

cd

user_dir="../usr/var/lib/proot-distro/installed-rootfs/debian/home/"

# Get the username from the user directory
username=$(basename "$user_dir"/*)

echo "Proot Username: $username"
echo ""

ls ../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/
echo ""

read -p "Choose the .desktop filename (with or without '.desktop' extension) that you want to copy into the menu (or enter 'q' to quit): " varname

if [[ $varname == "q" ]]; then
  echo "Quitting..."
  exit 0
fi

if [[ ! $varname == *.desktop ]]; then
  varname="$varname.desktop"
fi

cp "../usr/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/$varname" "../usr/share/applications/"
sed -i "s/^Exec=\(.*\)$/Exec=proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 \1/" "../usr/share/applications/$varname"

echo "Operation completed successfully!"
