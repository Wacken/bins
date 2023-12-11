#!/usr/bin/env bash
set -euo pipefail

cd ~/Files/Org
git pull
git add .
git commit -m "Sync from $(hostname) $(date +"%Y-%m-%d %H:%M:%S")"
git push
