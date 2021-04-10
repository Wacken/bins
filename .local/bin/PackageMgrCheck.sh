#!/bin/bash

if (which rpm &> /dev/null);then
    item_rpm=1
    echo "you have rpm"
else
    item_rpm=0
fi

if (which flatpak &> /dev/null);then
    item_flatpak=1
    echo "you have flatpak"
else
    item_flatpak=0
fi

if (which dnf &> /dev/null);then
    item_dnfyum=1
    echo "You have the dnf package manager."
elif (which yum &> /dev/null);then
    item_dnfyum=1
    echo "You have the yum package manager."
else
    item_dnfyum=0
fi

redhatscore=$[$item_rpm + $item_dnfyum + $item_flatpak]

if (which dpkg &> /dev/null);then
    item_dpkg=1
    echo "You have the basic dpkg utility."
else
    item_dpkg=0
fi

if (which apt &> /dev/null);then
    item_aptaptget=1
    echo "you have flatpak"
else
    item_aptaptget=0
fi

if (which snap &> /dev/null);then
    item_snap=1
    echo "you have snap"
else
    item_snap=0
fi

debianscore=$[$item_dpkg + $item_aptaptget + $item_snap]

if (which pacman &> /dev/null);then
    item_pacman=1
    echo "you have pacman"
else
    item_pacman=0
fi

if (which yay &> /dev/null);then
    item_yay=1
    echo "you have yay"
else
    item_yay=0
fi

archscore=$[$item_pacman + $item_yay]

if [ $debianscore -gt $redhatscore ];then
    echo "Most likely you have debian-based distro"
elif [ $redhatscore -gt $debianscore ];then
    echo "Most likely you have red-hat-based distro"
elif [ $archscore -gt $debianscore ] || [ $archscore -gt $redhatscore ];then
    echo "Most likely you are a ultra chad arch user"
fi
