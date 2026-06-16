#!/usr/bin/env bash
#
# backup.sh - config-driven backup script with logging

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/backup.conf"

source "${SCRIPT_DIR}/lib/utils.sh"
source "$CONFIG_FILE"

LOG_DIR="${LOG_DIR:-${SCRIPT_DIR}/logs}"
mkdir -p "$BACKUP_DEST" "$LOG_DIR"
LOG_FILE="${LOG_DIR}/backup_$(date +%Y-%m-%d).log"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_PATH="${BACKUP_DEST}/backup_${TIMESTAMP}.tar.gz"

log_info "Creating archive: $ARCHIVE_PATH"
tar -czf "$ARCHIVE_PATH" "${SOURCE_DIRS[@]}"
log_info "Backup complete."