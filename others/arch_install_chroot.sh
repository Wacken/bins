#!/usr/bin/env bash

user=$1
password=$2
fast=$3
partition=$4
hostname=$5

if [ "$fast" -eq "1" ]; then
    echo 'Setting up mirrors'
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
    rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
else
    echo 'Skipping mirror ranking because fast'
fi

echo "time zone settings"
timedatectl set-ntp true
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
timedatectl set-timezone Europe/Berlin
hwclock --systohc

echo "set locale"
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo "set keyboard layout"
echo 'KEYMAP=dvorak-programmer' > /etc/vconsole.conf

echo "setup hostname"
echo $hostname > /etc/hostname

echo "setup network"
cat << EOF >> /etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname
EOF
pacman -S networkmanager --noconfirm
systemctl enable NetworkManager.service

echo 'Building'
mkinitcpio -P


echo 'Installing bootloader'
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Setting up user'
read -t 1 -n 1000000 discard      # discard previous input
echo 'root:'$password | chpasswd
useradd -m -G wheel $user
echo $user:$password | chpasswd
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

exit
