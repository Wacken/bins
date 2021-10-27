#!/usr/bin/env bash
set -eo pipefail

echo "Do you already have an SSH key uploaded to github [y/n]"
read -n 1 answer
if [ "$answer" = "n" ]; then
    ssh-keygen -t ed25519 -C "sebastianwalchi@gmail.com"
    sudo mkdir /root/.ssh
    sudo cp ~/.ssh/id_* /root/.ssh/
    echo "created new ssh key"
    exit
fi

echo "Do you have already moved the GPG keys [y/n/x]"
read -n 1 answer
if [ "$answer" = "y" ]; then
    echo "setting up gpg"
    mkdir -p ~/.local/share/gnupg
    sudo chmod 700 ~/.local/share/gnupg
    gpg --import ~/my_private_key.asc
    gpg --import ~/my_public_key.asc
    shred -u ~/my_public_key.asc
    shred -u ~/my_private_key.asc
elif [ "$answer" = "x" ]; then
     echo "skipping setup"
else
    cat <<EOF
move the gpg key first, otherwise no password management
To export use
gpg --export-secret-keys -a keyid > my_private_key.asc
gpg --export -a keyid > my_public_key.asc
and move them to the home folder
of this machine
EOF
    exit
fi

echo
if [ -z "$1" ]; then
    echo "Enter etc branch name"
    read branchName
else
    branchName=$1
fi

echo 'set umask for file creation'
umask a+r,u+w

# sudo pacman -S fakeroot binutils make gcc --noconfirm
echo 'Install yay AUR manager'
git clone https://aur.archlinux.org/yay.git
(
    cd yay/
    makepkg -sri
)
yay --noconfirm
rm -rf yay/

echo 'setup etc files? [y/n]'
if [ "$answer" = "y" ]; then
(
    cd /etc
    su -c "umask a+r,u+w
    git init
    touch .gitignore
    chmod a+w .gitignore
    git status --porcelain | grep '^??' | cut -c4- > .gitignore
    chmod a-w .gitignore
    touch .init
    git add .
    git commit -m 'Init commit'
    git remote add origin git@github.com:Wacken/.etc-files.git
    rm .gitignore
    rm default/grub
    rm locale.gen
    rm mkinitcpio.conf
    rm pacman.conf
    rm sudoers
    rm vconsole.conf
    git pull -f origin master --allow-unrelated-histories
    git commit -m 'init merge'
    git branch $branchName
    git checkout $branchName
    sed -i 's/^fstab//' /etc/.gitignore
    sed -i 's/^hosts//' /etc/.gitignore
    sed -i 's/^hostname//' /etc/.gitignore
    git add .gitignore
    git add fstab
    git add hosts
    git add hostname
    git commit -m 'Initial $branchName commit'" root
)
fi
# git push --set-upstream origin $branchName ;; removed as doesn't work reliably

yay -Sy # multilib database download from new pacman.conf

echo 'root level Visuals? [y/n]'
if [ "$answer" = "y" ]; then
yay -S terminus-font --noconfirm
mkdir ~/opt/
(
    cd ~/opt
    git clone git@github.com:xenlism/Grub-themes.git
    cd Grub-themes/xenlism-grub-arch-1080p
    sudo ./install.sh
)
rm -rf ~/opt/Grub-themes
# for hiding grub menue from etc and safety for grub theme
sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

echo 'Setup emacs? [y/n]'
if [ "$answer" = "y" ]; then
sudo pacman -S emacs --noconfirm
git clone git@github.com:Wacken/doom.git ~/.config/doom
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.config/emacs
~/.config/emacs/bin/doom install
~/.config/emacs/bin/doom sync
fi

echo 'setup password manager? [y/n]'
if [ "$answer" = "y" ]; then
sudo pacman -S pass --noconfirm
mkdir ~/.local/share/pass
git clone git@github.com:Wacken/passstore.git ~/.local/share/pass
sudo pacman -S xclip --noconfirm
fi

echo 'setup Org files? [y/n]'
if [ "$answer" = "y" ]; then
mkdir ~/Files
git clone git@github.com:Wacken/Org-Files.git ~/Files/Org
fi

echo 'setup local scripts? [y/n]'
if [ "$answer" = "y" ]; then
git clone git@github.com:Wacken/bins.git ~/Files/scripts
sudo pacman -S stow --noconfirm
mkdir ~/.local/bin
stow -d ~/Files/scripts -t ~ -R bins -v
fi

echo 'setup xmonad? [y/n]'
if [ "$answer" = "y" ]; then
mkdir ~/.local/share/xmonad
sudo pacman -S xmonad xmonad-contrib xmobar kitty dmenu --noconfirm
fi

echo 'create default environment files'
mkdir ~/.cache/bash
touch ~/.cache/bash/history

echo 'Install timeshift? [y/n]'
if [ "$answer" = "y" ]; then
yay -S timeshift
fi

echo 'Install yadm? [y/n]'
if [ "$answer" = "y" ]; then
yay -S --answerdiff N --answerclean N yadm
yadm clone git@github.com:Wacken/.dotFiles.git
yadm reset --hard
fi

echo 'install tools? [y/n]'
if [ "$answer" = "y" ]; then
yay -S rclone rsync simple-mtpfs udiskie cronie
fi

echo 'install default programs? [y/n]'
if [ "$answer" = "y" ]; then
sudo pacman -S dunst vlc feh ufw flameshot --noconfirm
sudo systemctl enable --now cronie
sudo systemctl enable --now ufw
fi

echo 'fonts setup? [y/n]'
if [ "$answer" = "y" ]; then
sudo pacman -S ttf-fira-code ttf-dejavu noto-fonts-emoji --noconfirm
fi

echo 'install browser? [y/n]'
if [ "$answer" = "y" ]; then
# gtk2 needed,as you want to popup a pinentry-gtk-2 window from browser to input gpg key
yay -S brave-bin browserpass-chromium gtk2
fi

echo 'Setup standard alternative programs? [y/n]'
if [ "$answer" = "y" ]; then
sudo pacman -S exa bat ripgrep fd --noconfirm
fi

echo 'install other programms? [y/n]'
if [ "$answer" = "y" ]; then
yay -S youtube-music-bin discord surfshark-vpn redshift-minimal nitrogen thunderbird
# yay -S picom-joanburg-git nautilus simplescreenrecorder libreoffice-still foxitreader
fi

echo 'install sound with bluetooth? [y/n]'
if [ "$answer" = "y" ]; then
yay -S pavucontrol pulseaudio-alsa pulseaudio-bluetooth bluez-utils
sudo sytemctl enable --now bluetooth
bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent
# sudo pacman -S alsa-utils --noconfirm # for alsamixer and amixer
fi

echo 'instal games? [y/n]'
if [ "$answer" = "y" ]; then
sudo pacman -S wine winetricks wine-mono wine-gecko --noconfirm
yay -S proton-ge-custom-bin protontricks
sudo pacman -S lutris --noconfirm
fi

<<<<<<< HEAD
echo 'install japanese language input? [y/n]'
if [ "$answer" = "y" ]; then
=======
echo 'install printer support'
sudo pacman -S cups print-manager --noconfirm
yay -S brother-mfc-l2700dn

echo 'install japanese language input'
>>>>>>> 5fc4720a863c1e672c050b4e70a64d334f35b536
yay -S adobe-source-han-sans-jp-fonts ibus-mozc
echo 'setup ibus in input ctrl space, in languages add mozc and dvorak programmer
and in the advanced tab set "use system keyboard"'
ibus-setup
fi
