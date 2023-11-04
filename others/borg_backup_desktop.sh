#!/usr/bin/env bash
set -euo pipefail

~/Files/scripts/others/borg_backup.sh "/data"
~/Files/scripts/others/borg_backup.sh "/backup"
