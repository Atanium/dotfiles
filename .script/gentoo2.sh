#!/bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
mount /dev/nvme0n1p1 /efi
emerge-webrsync
eselect profile set 3
emerge --oneshot app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

cat << 'EOF' > /etc/portage/make.conf
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
MAKEOPTS="-j8 -l9"
RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"
GENTOO_MIRRORS="https://distfiles.gentoo.org"
VIDEO_CARDS="amdgpu radeonsi"
ACCEPT_KEYWORDS="amd64"
ACCEPT_LICENSE="*"
USE="dist-kernel -kde -systemd -aqua -css -a52 -cjk -gnome -qt4 -qt5 -ldap -3df -berkdb -clamav -coreaudio -ipod -iee1394 -emacs -xemacs -gtk -motif lto -emboss -3df -altivec -smartcard -cups -ibm alsa x -nls -nas -neon -nntp -quicktime -consolekit -policykit graphite"
LC_MESSAGES=C.utf8
EOF

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
reboot
