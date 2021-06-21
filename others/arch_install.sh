#!/bin/bash
set -eo pipefail

#to download: curl -o arch_install.sh -L https://tinyurl.com/e4nx66fm

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
	# ramSizeHibernation=$(($ramSizeSquare + $ramSize))
	swapEnd=$(echo "261 + $ramSizeSquare * 1000" | bc)MB
	echo "swap Ends at $swapEnd"

	toSearchDisk=$(basename $partition)
	diskSize=$(lsblk | grep "$toSearchDisk\b" | tr -s ' ' | cut -d' ' -f4 | tr -d '[:alpha:]')
	rootSize=$(echo "$diskSize * 0.25" | bc)
	rootSizeFormated=${float%.*}
	if ((rootSizeFormated <= 8)); then
		rootSizeFormated=8
	elif ((rootSizeFormated >= 40)); then
		rootSizeFormated=40
	fi
	rootSizeEnd=$(echo "${swapEnd//[[:alpha:]]/} + $rootSizeFormated * 1000" | bc)MB
	echo "root Ends at $rootSizeEnd"

	parted -s $partition mklabel gpt

	parted -s $partition mkpart "EFI_system_partition" fat32 1MiB 261MiB
	parted -s $partition set 1 esp on
	parted -s $partition mkpart "swap_partition" linux-swap 261MiB $swapEnd
	parted -s $partition mkpart "root_partition" ext4 $swapEnd $rootSizeEnd
    parted -s $partition mkpart "home_partition" ext4 $rootSizeEnd 100%
fi

mkfs.fat -F32 ${partition}1
mkswap ${partition}2
swapon ${partition}2
mkfs.ext4 ${partition}3
mkfs.ext4 ${partition}4

mount ${partition}3 /mnt
mkdir /mnt/efi
mount ${partition}1 /mnt/efi
mkdir /mnt/home/
mount ${partition}4 /mnt/home

pacstrap /mnt base base-devel linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

modprobe efivarfs

curl -Lo /mnt/arch_install_chroot.sh https://raw.githubusercontent.com/Wacken/bins/master/others/arch_install_chroot.sh
chmod +x arch_install_chroot.sh
arch-chroot /mnt /bin/bash arch_install_chroot.sh "$user" "$password" "$hostname" "$partition"

umount -R /mnt
reboot
