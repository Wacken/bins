#!/usr/bin/env bash
set -euo pipefail

cat ~/Downloads/history.csv | cut -d , -f 6 | rg holodex | rg watch
