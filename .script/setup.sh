#!/bin/bash
sudo pacman -Syu
sudo pacman -S --needed git base-devel nano brightnessctl river foot ttf-liberation ttf-dejavu fuzzel fastfetch 
sudo chmod +s /usr/bin/reboot
sudo chmod +s /usr/bin/poweroff
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd
wget https://raw.githubusercontent.com/Atanium/dotfiles/refs/heads/main/.config/init
mkdir -p ~/.config/river
mkdir ~/.config/foot
mkdir -p ~/.config/systemd/user
cp init ~/.config/river/init
rm init
cp /etc/xdg/foot/foot.ini ~/.config/foot/foot.ini

cat > "$HOME/.config/systemd/user/riverstartup.service" <<EOF
[Unit]
Description=Run river at user login
After=default.target

[Service]
Type=oneshot
ExecStart=/usr/bin/river
RemainAfterExit=true

[Install]
WantedBy=default.target
EOF

#systemctl --user enable riverstartup.service

sudo cat > "/etc/modprobe.d/rtw8852be.conf" <<EOP
options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y
options rtw89pci disable_aspm_l1=y disable_aspm_l1ss=y
options rtw89_core disable_ps_mode=y
options rtw89core disable_ps_mode=y
EOP

yay -S ungoogled-chromium-bin
