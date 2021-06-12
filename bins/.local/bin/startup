#!/usr/bin/env bash

exec &>/dev/null

nohup ~/.local/bin/reminders.sh &
nohup emacs --eval='(org-agenda nil "G")' &
nohup emacs -f elfeed &
nohup brave &
nohup youtube-music-bin &
sleep 5
wmctrl -r "Doom Emacs" -t 8
wmctrl -r "YouTube Music" -t 6
