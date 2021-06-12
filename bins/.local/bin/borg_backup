#!/usr/bin/env bash
set -euo pipefail

export BORG_PASSCOMMAND="pass Organication/borg-backup"

MOUNTPOINT="$1"
if [[ ! -d "$MOUNTPOINT" ]]; then
    echo "No such file or directory: $MOUNTPOINT"
    exit 2
fi
TARGET="$MOUNTPOINT/Backups/borg"

DATE=$(date --iso-8601)-$(hostname)
BORG_OPTIONS="--stats --progress --compression=lzma"
TO_BACKUP="$MOUNTPOINT/Windows_backup $MOUNTPOINT/Keep $MOUNTPOINT/Japanese $MOUNTPOINT/Remember $MOUNTPOINT/Books $MOUNTPOINT/Documents $MOUNTPOINT/Learn $MOUNTPOINT/Music $MOUNTPOINT/Pictures"

borg --version
echo "Starting backup for $DATE"
echo "Make backup at $TARGET"
echo "to Backup $TO_BACKUP"

borg create $BORG_OPTIONS $TARGET::$DATE-$$-system $TO_BACKUP
