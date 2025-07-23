#!/bin/bash
(echo g; echo n; echo 1; echo 2048; echo +1G; echo t; echo 1; echo n; echo 2; echo ""; echo +16G; echo t; echo 2; echo 19; echo n; echo 3; echo ""; echo ""; echo t; echo 3; echo 23; echo w; echo q) | fdisk /dev/nvme0n1
mkfs.xfs -f /dev/nvme0n1p3
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
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
echo "TYPE THIS IN: chroot /mnt/gentoo /bin/bash"
