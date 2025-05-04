#!/bin/bash

BACKUP_DIR="/data/Backups/postgresql"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="pg_backup_$TIMESTAMP.sql"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Perform the backup
sudo -u postgres pg_dumpall > "$BACKUP_DIR/$FILENAME"

# Optional: keep only the last 10 backups
ls -tp "$BACKUP_DIR" | grep -v '/$' | tail -n +11 | xargs -I {} rm -- "$BACKUP_DIR/{}"
