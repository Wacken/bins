#!/usr/bin/env bash
set -euo pipefail

MOUNTPOINT="$1"
if [[ ! -d "$MOUNTPOINT" ]]; then
    echo "No such file or directory: $MOUNTPOINT"
    exit 2
fi
TARGET="$MOUNTPOINT/Backups/borg"
DATA="/data"

DATE=$(date --iso-8601)-$(hostname)
BORG_OPTIONS="--stats --progress --compression=lzma"
TO_BACKUP="$DATA/Windows_backup $DATA/Keep $DATA/Japanese $DATA/Remember $DATA/Books $DATA/Documents $DATA/Learn $DATA/Music $DATA/Pictures"

# passwdFile=$(cat <(gpg -d /home/wacken/.local/share/gnupg/borg_backup.gpg 2> /dev/null))
passwd="${2:-xxx}"
if [[ $passwd == "xxx" ]]; then
    export BORG_PASSPHRASE=""
else
    export BORG_PASSPHRASE="$passwd"
fi

borg --version
echo "Starting backup for $DATE"
echo "Make backup at $TARGET"
echo "to Backup $TO_BACKUP"

borg create $BORG_OPTIONS $TARGET::$DATE-$$-system $TO_BACKUP
