#!/usr/bin/env bash
set -euo pipefail

nohup emacs -f elfeed &
nohup emacs --eval='(org-agenda nil "G")' &
nohup zsh -c yay &
nohup brave &
nohup youtube-music-bin &
