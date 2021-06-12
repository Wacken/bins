#!/usr/bin/env bash
set -euo pipefail

WID=$(xdotool search "brave-browser" | head -1)
xdotool windowactivate --sync $WID
sleep 1
# xdotool key --clearmodifiers ctrl+t
xdotool key --clearmodifiers "ctrl+w"
sleep 1
links=$(cat "/home/wacken/Downloads/history.csv" | cut -d , -f 6 | rg holodex | rg watch | uniq)
echo ${#links}
for x in $links; do
      echo "$x"
      xdg-open "$x"
      xdotool key x
done
# xdotool key T
# xdotool type "okakoro"
# wait
# xdotool key Return
