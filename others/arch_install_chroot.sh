#!/usr/bin/env bash

user=$1
password=$2
hostname=$3
partition=$4

echo "time zone settings; set it like Europe/Berlin"
read -r timezone
timedatectl set-ntp true
ln -s "/usr/share/zoneinfo/$timezone" /etc/localtime
timedatectl set-timezone "$timezone"
hwclock --systohc

echo "set locale"
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >/etc/locale.conf

echo "set keyboard layout"
echo 'KEYMAP=dvorak-programmer' >/etc/vconsole.conf

echo "pacman init"
pacman -Sy

echo 'mirror-update; set country like Germany'
read -r country
sudo pacman -S reflector --noconfirm
sudo reflector -c "$country" -a 12 -p https -p http --sort rate --save /etc/pacman.d/mirrorlist

echo "setup hostname"
echo "$hostname" >/etc/hostname

echo "setup network"
cat <<EOF >>/etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname
EOF
pacman -S networkmanager --noconfirm
systemctl enable NetworkManager.service

echo 'Building'
mkinitcpio -P

echo 'Installing microcode for INTEL, before bootloader'
pacman -S intel-ucode --noconfirm

echo 'Installing bootloader'
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Install git'
pacman -S git --noconfirm
git config --global init.deafultBranch master
git config --global user.email "sebastianwalchi@gmail.com"
git config --global user.name "wacken"
sudo git config --global init.deafultBranch master
sudo git config --global user.email "sebastianwalchi@gmail.com"
sudo git config --global user.name "wacken"

echo 'Install ssh'
pacman -S openssh --noconfirm
systemctl enable --now sshd

echo 'Install graphicals'
# pacman -S xorg xorg-xinit xterm --noconfirm
pacman -S xorg-server xorg-xinit --noconfirm
# necessary drivers
pacman -S nvidia-lts nvidia-utils nvidia-settings --noconfirm
# https://github.com/lutris/docs/blob/master/InstallingDrivers.md
pacman -S vulkan-icd-loader lib32-vulkan-icd-loader lib32-nvidia-utils --noconfirm
# find xkbmodel with 'setxkbmap -print | grep geometry'
# sudo localectl --no-convert set-x11-keymap us pc105 dvp

echo 'Setting up user'
read -t 1 -n 1000000 _ # discard previous input

pacman -S sudo --noconfirm

echo 'root:'$password | chpasswd
useradd -m -G wheel,audio,video,optical,storage,input $user
echo $user:$password | chpasswd
echo '%wheel ALL=(ALL) ALL' >>/etc/sudoers

exit
