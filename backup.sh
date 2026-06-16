#!/usr/bin/env bash
#
# backup.sh - basic backup script with logging

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

SOURCE_DIR="/home/user/documents"
BACKUP_DEST="/var/backups/myapp"
LOG_DIR="${SCRIPT_DIR}/logs"

mkdir -p "$BACKUP_DEST" "$LOG_DIR"
LOG_FILE="${LOG_DIR}/backup_$(date +%Y-%m-%d).log"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_PATH="${BACKUP_DEST}/backup_${TIMESTAMP}.tar.gz"

log_info "Creating archive: $ARCHIVE_PATH"
tar -czf "$ARCHIVE_PATH" "$SOURCE_DIR"
log_info "Backup complete."