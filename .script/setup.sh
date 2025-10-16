#!/bin/bash
mkdir -p ~/.config/systemd/user

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

systemctl --user enable riverstartup.service

sudo pacman -Syu
sudo pacman -S --needed git base-devel nano brightnessctl river foot ttf-liberation ttf-dejavu fuzzel fastfetch slurp grim
#sudo chmod +s /usr/bin/reboot
#sudo chmod +s /usr/bin/poweroff
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd
wget https://raw.githubusercontent.com/Atanium/dotfiles/refs/heads/main/.config/init
mkdir ~/.config/river
mkdir ~/.config/foot
mv init ~/.config/river/init
chmod +x ~/.config/river/init
cp /etc/xdg/foot/foot.ini ~/.config/foot/foot.ini
sed -i '11s/.*/font=monospace:size=12/' ~/.config/foot/foot.ini

echo "options rtw89_pci disable_clkreq=y disable_aspm_l1=y disable_aspm_l1ss=y" > 70-rtw89.conf
sudo mv 70-rtw89.conf /usr/lib/modprobe.d/

yay -S ungoogled-chromium-bin
