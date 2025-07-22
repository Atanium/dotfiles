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
cat << 'EOF' | chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
mount /dev/nvme0n1p1 /efi
emerge --sync
eselect profile set 2
emerge --oneshot app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags
emerge --verbose --update --deep --changed-use @world
emerge --depclean
ln -sf ../usr/share/zoneinfo/Asia/Dubai /etc/localtime
echo -e "en_US ISO-8859-1 \nen_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set 2
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
emerge sys-kernel/linux-firmware
echo -e "sys-kernel/installkernel \nsys-boot/uefi-mkconfig \napp-emulation/virt-firmware" > /etc/portage/package.accept_keywords/installkernel
echo "sys-kernel/installkernel efistub dracut" > /etc/portage/package.use/installkernel
emerge sys-kernel/installkernel
mkdir -p /efi/EFI/Gentoo
emerge sys-kernel/gentoo-kernel
emerge --depclean
emerge @module-rebuild
emerge --config sys-kernel/gentoo-kernel
echo -e "/dev/nvme0n1p1   /efi        vfat    defaults     0 2\n/dev/nvme0n1p2   none         swap    sw                   0 0\n/dev/nvme0n1p3   /            xfs    defaults,noatime              0 1" >> /etc/fstab
echo enoch > /etc/hostname
echo -e "127.0.0.1     enoch.homenetwork enoch localhost\n::1           enoch.homenetwork enoch localhost" > /etc/hosts
echo "micro8bus8tent" | passwd --stdin
emerge app-admin/sysklogd
rc-update add sysklogd default
emerge sys-apps/mlocate
emerge app-shells/bash-completion
emerge net-misc/chrony
rc-update add chronyd default
emerge sys-block/io-scheduler-udev-rules sys-fs/xfsprogs sys-fs/dosfstools
emerge net-wireless/wpa_supplicant
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
EOF
reboot
