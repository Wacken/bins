#!/usr/bin/env bash
set -eo pipefail

echo "Do you already have an SSH key uploaded to github [y/n]"
read -n -r 1 answer
if [ "$answer" = "n" ]; then
    ssh-keygen -t ed25519 -C "sebastianwalchi@gmail.com"
    sudo mkdir /root/.ssh
    sudo cp ~/.ssh/id_* /root/.ssh/
    echo "created new ssh key"
    exit
fi

echo "Do you have already moved the GPG keys [y/n/x] (x is skipping)"
read -n -r 1 answer
if [ "$answer" = "y" ]; then
    echo "setting up gpg"
    mkdir -p ~/.local/share/gnupg
    sudo chmod 700 ~/.local/share/gnupg
    gpg --import ~/my_private_key.asc
    gpg --import ~/my_public_key.asc
    shred -u ~/my_public_key.asc
    shred -u ~/my_private_key.asc
    echo ""
    cat <<EOF
You also need to change the trust of this key, otherwise some stuff won't work. Thefore use
(https://stackoverflow.com/questions/33361068/gnupg-there-is-no-assurance-this-key-belongs-to-the-named-user)

gpg --edit-key <KEY_ID>
gpg> trust

1 = I don't know or won't say
2 = I do NOT trust
3 = I trust marginally
4 = I trust fully
5 = I trust ultimately
m = back to the main menu

Be sure you've changed this. After that please:
EOF

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
    read -r branchName
else
    branchName=$1
fi

echo 'set umask for file creation'
umask a+r,u+w

# sudo pacman -S fakeroot binutils make gcc --noconfirm
echo 'Install paru AUR manager'
git clone https://aur.archlinux.org/paru.git
(
    cd paru/
    makepkg -sri
)
paru --noconfirm
rm -rf paru/

echo 'setup etc files? [y/n]'
read -n -r 1 answer
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

paru -Sy --noconfirm # multilib database download from new pacman.conf

echo 'root level Visuals? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S terminus-font os-prober --noconfirm # os-prober to find potential dual-boot
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
read -n -r 1 answer
if [ "$answer" = "y" ]; then
sudo pacman -S emacs --noconfirm
git clone git@github.com:Wacken/doom.git ~/.config/doom
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.config/emacs
~/.config/emacs/bin/doom install
~/.config/emacs/bin/doom sync
fi

echo 'setup zsh as default? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S zsh zsh-extract-git zsh-fast-syntax-highlighting --noconfirm
chsh -s /usr/bin/zsh
fi

echo 'setup password manager? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
sudo pacman -S pass xclip --noconfirm
mkdir ~/.local/share/pass
git clone git@github.com:Wacken/passstore.git ~/.local/share/pass
fi

echo 'setup Org files? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
mkdir ~/Files
git clone git@github.com:Wacken/Org-Files.git ~/Files/Org
fi

echo 'setup local scripts? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
git clone git@github.com:Wacken/bins.git ~/Files/scripts
sudo pacman -S stow --noconfirm
mkdir ~/.local/bin
stow -d ~/Files/scripts -t ~/.local/bin -R bins -v
fi

echo 'setup xmonad (from https://github.com/Axarva/dotfiles-2.0#arch)? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
mkdir ~/.local/share/xmonad
git clone git@github.com:Axarva/dotfiles-2.0.git
(
    cd dotfiles-2.0
    ./install-on-arch.sh
)
paru -Rns alacritty betterlockscreen xorg-xinput xorg-bdftopcf xorg-docs xorg-font-util xorg-fonts-100dpi xorg-fonts-75dpi xorg-iceauth xorg-mkfontscale xorg-server-devel xorg-server-xephyr xorg-server-xnest xorg-server-xvfb xorg-sessreg xorg-smproxy xorg-x11perf xorg-xbacklight xorg-xcmsdb xorg-xcursorgen xorg-xdriinfo xorg-xev xorg-xgamma xorg-xhost xorg-xkbevd xorg-xkbutils xorg-xkill xorg-xlsatoms xorg-xlsclients xorg-xpr xorg-xrefresh xorg-xsetroot xorg-xvinfo xorg-xwayland xorg-xwd xorg-xwininfo xorg-xwud
rm -rf ~/bin
rm -rf ~/.srcs
rm -rf ~/.config/alacritty.yml
paru -S betterlockscreen xorg-xinput rofi-pass --noconfirm
fi

echo 'create default environment files'
mkdir ~/.cache/bash
touch ~/.cache/bash/history

echo 'Install yadm? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S --answerdiff N --answerclean N yadm
yadm clone git@github.com:Wacken/.dotFiles.git
yadm reset --hard
fi

echo 'install tools? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S rclone rsync simple-mtpfs udiskie cronie
fi

echo 'install default programs? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
sudo pacman -S dunst vlc feh ufw flameshot --noconfirm
sudo pacman -S inetutils # for hostname command in backup script
sudo systemctl enable --now cronie
sudo systemctl enable --now ufw
fi

echo 'fonts setup? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
sudo pacman -S ttf-fira-code ttf-dejavu noto-fonts-emoji --noconfirm
fi

echo 'install browser? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
# gtk2 needed,as you want to popup a pinentry-gtk-2 window from browser to input gpg key
paru -S brave-bin browserpass-chromium gtk2 --noconfirm
fi

echo 'rust install'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo 'Setup standard rust programs? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
sudo pacman -S exa bat ripgrep fd btop dust starship zoxide --noconfirm
fi

echo 'install other programms? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S youtube-music-bin discord redshift-minimal --noconfirm
# paru -S picom-joanburg-git nautilus simplescreenrecorder libreoffice-still foxitreader --noconfirm
fi

echo 'install sound with bluetooth? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S pipewire pipewire-alsa pipewire-pulse bluez-utils pavucontrol --noconfirm
sudo systemctl enable --now bluetooth
bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent
# sudo pacman -S alsa-utils --noconfirm # for alsamixer and amixer
fi

echo 'install timeshift [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S timeshift --noconfirm
fi

echo 'install games? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
sudo pacman -S wine winetricks wine-mono wine-gecko lib32-libpulse --noconfirm
paru -S proton-ge-custom-bin protontricks --noconfirm
sudo pacman -S lutris --noconfirm
fi

echo 'install japanese language input? [y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S adobe-source-han-sans-jp-fonts ibus-mozc --noconfirm
echo 'setup ibus in input ctrl space, in languages add mozc and dvorak programmer
and in the advanced tab set "use system keyboard"'
ibus-setup
fi

echo 'install yomichan?'
echo 'go to https://foosoft.net/projects/yomichan/#dictionaries and download the dicts'
echo 'dont forget too import the settings'


echo 'install shell tools emacs[y/n]'
read -n -r 1 answer
if [ "$answer" = "y" ]; then
paru -S shfmt shellcheck bash-language-server
fi
