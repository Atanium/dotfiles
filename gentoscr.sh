#!/bin/bash
(echo g; echo n; echo 1; echo 2048; echo +1G; echo Y; echo t; echo 1; echo n; echo 2; echo ""; echo +16G; echo Y; echo t; echo 2; echo 19; echo n; echo 3; echo ""; echo ""; echo t; echo 3; echo 23; echo w; echo q) | fdisk /dev/nvme0n1
mkfs.xfs /dev/nvme0n1p3
mkfs.vfat -F 32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mkdir --parents /mnt/gentoo
mount /dev/nvme0n1p3 /mnt/gentoo
mkdir --parents /mnt/gentoo/efi
cd /mnt/gentoo
chronyd -q
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/20250720T165240Z/stage3-amd64-desktop-openrc-20250720T165240Z.tar.xz
tar xpvf stage3-amd64-desktop-openrc-20250720T165240Z.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo

cat << 'EOF' > /mnt/gentoo/etc/portage/make.conf
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
MAKEOPTS="-j8 -19"
CHOST="x86_64-pc-linux-gnu"
RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"
GENTOO_MIRRORS="https://distfiles.gentoo.org"
VIDEO_CARDS="amdgpu radeonsi"
ACCEPT_KEYWORDS="amd64"
ACCEPT_LICENSE="*"
USE="dist-kernel -kde -systemd -aqua -css -a52 -cjk -gnome -qt4 -qt5 -ldap -3df -berkdb -clamav -coreaudio -ipod -iee1394 -emacs -xemacs -gtk -motif lto -emboss -3df -altivec -smartcard -cups -ibm alsa x -nls -nas -neon -nntp -quicktime -consolekit -policykit graphite"
LC_MESSAGES=C.utf8
EOF

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
