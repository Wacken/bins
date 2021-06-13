#!/bin/bash

#tiny URL: https://tinyurl.com/e4nx66fm

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
	hostname=$4
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
	swapEnd=$((513 + $ramSizeSquare * 1024))MB

	toSearchDisk=$(basename $partition)
	diskSize=$(lsblk | grep "$toSearchDisk\b" | tr -s ' ' | cut -d' ' -f4 | tr -d '[:alpha:]')
	rootSizeFormated=$(printf "%.0d" $(echo "$diskSize * 0.25" | bc))
	if ((rootSizeFormated <= 4)); then
		rootSizeFormated=4
	elif ((rootSizeFormated >= 40)); then
		rootSizeFormated=40
	fi

	rootSizeEnd=$((${swapEnd//[[:alpha:]]/} + $rootSizeFormated * 1024))MB

	parted -s $partition mklabel gpt
	parted -s $partition mkpart primary fat32 1MB 513MB
	parted -s $partition mkpart primary linux-swap 513MB $swapEnd
	parted -s $partition mkpart primary ext4 $swapEnd $rootSizeEnd
    parted -s $partition mkpart primary ext4 $rootSizeEnd 100%
fi

mkfs.vfat ${partition}1
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

pacstrap /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

modprobe efivarfs
