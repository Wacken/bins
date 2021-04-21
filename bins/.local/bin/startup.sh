#!/usr/bin/env bash

nohup emacs -f elfeed &
nohup emacs --eval='(org-agenda nil "G")' &
nohup brave &
nohup youtube-music-bin &
