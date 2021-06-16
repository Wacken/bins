#!/bin/bash

#to download: curl -LO https://tinyurl.com/e4nx66fm -o arch_install.sh

if ! ls /sys/firmware/efi/efivars >/dev/null; then
	echo "The System didn't boot in EFI mode"
	exit 1
fi

loadkeys dvorak-programmer

if [ -z "$1" ]; then
	echo "Enter your username: "
	read user
else
	user=$1
fi

if [ -z "$2" ]; then
	echo "Enter your master password: "
	read -s password
else
	password=$2
fi

if [ -z "$3" ]; then
	echo "Enter Hostname:"
	read hostname
else
	hostname=$3
fi

timedatectl set-ntp true

echo "Enter (N/n) if you don't have a standard setup (existing EFI partition, dual boot)"
lsblk
echo "Enter partiton to install on(i.e /dev/sda):"
read partition

if [ $partition = "n" ] || [ $partition = "N" ]; then
	echo "No standard setup, set partitions manually"
	exit 1
else
	ramSize=$(free -ht | sed -n 2p | tr -s ' ' | cut -d' ' -f2 | tr -d '[:alpha:]')
	ramSizeSquare=$(echo "sqrt($ramSize) + 1" | bc)
	ramSizeHibernation=$(($ramSizeSquare + $ramSize))
	swapEnd=$((261 + $ramSizeSquare * 1000))MiB
	echo "swap Ends at $swapEnd"

	toSearchDisk=$(basename $partition)
	diskSize=$(lsblk | grep "$toSearchDisk\b" | tr -s ' ' | cut -d' ' -f4 | tr -d '[:alpha:]')
	rootSizeFormated=$(printf "%.0d" $(echo "$diskSize * 0.25" | bc))
	if ((rootSizeFormated <= 4)); then
		rootSizeFormated=4
	elif ((rootSizeFormated >= 40)); then
		rootSizeFormated=40
	fi
	rootSizeEnd=$((${swapEnd//[[:alpha:]]/} + $rootSizeFormated * 1000))MiB
	echo "root Ends at $rootSizeEnd"

	parted -s $partition mklabel gpt

	parted -s $partition mkpart "EFI system partition" fat32 1MiB 261MiB
	parted -s $partition set 1 esp on
	parted -s $partition mkpart "swap partition" linux-swap 261MiB $swapEnd
	parted -s $partition mkpart "root partition" ext4 $swapEnd $rootSizeEnd
    parted -s $partition mkpart "home partition" ext4 $rootSizeEnd 100%
fi

mkfs.fat -F32 ${partition}1
mkswap ${partition}2
swapon ${partition}2
mkfs.ext4 ${partition}3
mkfs.ext4 ${partition}4

mkdir /mnt
mount ${partition}3 /mnt
mkdir /mnt/efi
mount ${partition}1 /mnt/efi
mkdir /mnt/home/
mount ${partition}4 /mnt/home

# pacstrap /mnt base linux linux-firmware

# genfstab -U /mnt >> /mnt/etc/fstab

# modprobe efivarfs

# curl -LO https://raw.githubusercontent.com/Wacken/bins/master/others/arch_install_chroot.sh\
# 	-o arch_chroot_install.sh
# chmod +x arch_chroot_install.sh
# ./arch_chroot_install.sh "$user" "$password" "$hostname" "$partition"

# umount -R /mnt
# reboot
# pacman -S
