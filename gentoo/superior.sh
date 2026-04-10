#!/bin/bash

// Making the partition table
wipefs --all /dev/nvme0n1
blkdiscard /dev/nvme0n1
(echo g; echo n; echo 1; echo ""; echo +1G; echo n; echo 2; echo ""; echo +16G; echo n; echo 3; echo ""; echo ""; echo t; echo 1; echo 1; echo t; echo 2; echo 19; echo t; echo 3; echo 23; echo w) | fdisk /dev/nvme0n1

// Making Filesystems
mkfs.vfat -F 32 /dev/nvm0n1p1
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mkfs.ext4 -f /dev/nvme0n1p3
mkdir --parents /mnt/gentoo
mount /dev/sda3 /mnt/gentoo
mkdir --parents /mnt/gentoo/efi

// Installing the Stage3 file
cd /mnt/gentoo
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/20260408T183104Z/stage3-amd64-desktop-openrc-20260408T183104Z.tar.xz
tar xpvf stage3-amd64-desktop-openrc-20260408T183104Z.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo

// Mounting other necessary points
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run 

// Chrooting into our system
chroot /mnt/gentoo /bin/bash <<"MPL"
source /etc/profile 
export PS1="(chroot) ${PS1}"

mount /dev/nvme0n1p1 /efi 
emerge-webrsync
eselect profile set 7

// Fetching and placing our make.conf file
wget https://raw.githubusercontent.com/Atanium/dotfiles/refs/heads/main/gentoo/make.conf
mv make.conf /etc/portage/make.conf

// Setting up bin pkgs
wget https://raw.githubusercontent.com/Atanium/dotfiles/refs/heads/main/gentoo/gentoobinhost.conf
mv gentoobinhost.conf /etc/portage/binrepos.conf/gentoobinhost.conf

// Fetching and placing the package.use file
wget https://raw.githubusercontent.com/Atanium/dotfiles/refs/heads/main/gentoo/global
mv global /etc/portage/package.use/global

// Emerging @world + cleanup
// WARNING THERE'S A HIGH CHANCE IT'LL FAIL RIGHT HERE
emerge --verbose --update --deep --changed-use @world
emerge --depclean

// Setting Timezone and locale
ln -sf ../usr/share/zoneinfo/Asia/Dubai /etc/localtime
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set #
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

// Installing firmware
emerge sys-kernel/linux-firmware sys-firmware/sof-firmware

// Kernel Configuration
emerge sys-kernel/installkernel
emerge sys-kernel/gentoo-kernel
emerge --depclean
emerge @module-rebuild
emerge --config sys-kernel/gentoo-kernel 

// Fstab setup
wget https://raw.githubusercontent.com/Atanium/dotfiles/refs/heads/main/gentoo/fstab 
mv fstab /etc/fstab

// Setting hostname
echo enoch > /etc/hostname

// Hosts file
wget https://raw.githubusercontent.com/Atanium/dotfiles/refs/heads/main/gentoo/hosts
mv hosts /etc/hosts

// Setup network
emerge --ask net-misc/networkmanager
rc-update add NetworkManager default
emerge --ask net-wireless/iw net-wireless/wpa_supplicant

// Root password
passwd

emerge --ask app-admin/sysklogd
rc-update add sysklogd default

emerge --ask sys-process/cronie
rc-update add cronie default

emerge --ask sys-apps/mlocate

emerge --ask app-shells/bash-completion

emerge --ask net-misc/chrony
rc-update add chronyd default

emerge --ask sys-block/io-scheduler-udev-rules

emerge --ask --verbose sys-boot/grub
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge --ask sys-boot/grub
grub-install --efi-directory=/efi
grub-mkconfig -o /boot/grub/grub.cfg


