#!/usr/bin/env bash
set -euo pipefail

echo "Do you already have an SSH key uploaded to github [y/n]"
read -n 1 answer
if [ "$answer" = "n" ]; then
    ssh-keygen -t ed25519 -C "sebastianwalchi@gmail.com"
    sudo cp ~/.ssh/id_* /root/.ssh/
    echo "created new ssh key"
    exit
fi

echo "Do you have already moved the GPG keys [y/n]"
read -n 1 answer
if [ "$answer" = "y" ]; then
    echo "setting up gpg"
    mkdir ~/.local/share/gnupg
    gpg --import ~/my_private_key.asc
    gpg --import ~/my_public_key.asc
    shred -u ~/my_public_key.asc
    shred -u ~/my_private_key.asc
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

echo 'setup etc files'
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
    git commit -m 'Initial $branchName commit'
    git push --set-upstream origin $branchName" root
)

# su -c 'rm .gitignore
# rm default/grub
# rm locale.gen
# rm mkinitcpio.conf
# rm pacman.conf
# rm sudoers
# rm vconsole.conf
# git pull origin master --allow-unrelated-histories
# git commit -m "merged"' root

echo 'root level Visuals'
yay -Sy # multilib database download from new pacman.conf
yay -S terminus-font
mkdir ~/opt/
(
    cd ~/opt
    git clone git@github.com:xenlism/Grub-themes.git
    cd Grub-themes/xenlism-grub-arch-1080p
    sudo ./install.sh
)
rm -rf ~/opt/Grub-themes

echo 'Setup emacs'
sudo pacman -S emacs --noconfirm
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.config/emacs
~/.config/emacs/bin/doom install
(
    cd ~/.config
    git clone git@github.com:Wacken/doom.git
)
~/.config/emacs/bin/doom sync

echo 'setup password manager'
sudo pacman -S pass --noconfirm
mkdir ~/.local/share/pass
git clone git@github.com:Wacken/passstore.git ~/.local/share/pass
sudo pacman -S browserpass browserpass-chromium --noconfirm

echo 'setup Org files'

echo 'setup local scripts'

echo 'setup xmonad'
sudo pacman -S xmonad xmonad-contrib xmobar kitty dmenu --noconfirm

echo 'create default environment files'
mkdir ~/.local/bin
mkdir ~/.cache/bash
touch ~/.cache/bash/history

echo 'Install yadm'
yay -S --answerdiff N --answerclean N yadm
yadm clone git@github.com:Wacken/.dotFiles.git
yadm reset --hard

echo 'install other programms'

echo 'Setup standard alternative programs'
sudo pacman -S exa bat rg fd --noconfirm
