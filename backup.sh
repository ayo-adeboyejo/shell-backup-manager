#!/usr/bin/env bash
#
# backup.sh - basic backup script (work in progress)

SOURCE_DIR="/home/user/documents"
BACKUP_DEST="/var/backups/myapp"

mkdir -p "$BACKUP_DEST"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_PATH="${BACKUP_DEST}/backup_${TIMESTAMP}.tar.gz"

echo "Creating archive: $ARCHIVE_PATH"
tar -czf "$ARCHIVE_PATH" "$SOURCE_DIR"
echo "Backup complete."