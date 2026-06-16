#!/usr/bin/env bash
#
# backup.sh - config-driven backup script with logging and validation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/backup.conf"

source "${SCRIPT_DIR}/lib/utils.sh"
source "$CONFIG_FILE"

LOG_DIR="${LOG_DIR:-${SCRIPT_DIR}/logs}"
mkdir -p "$BACKUP_DEST" "$LOG_DIR"
LOG_FILE="${LOG_DIR}/backup_$(date +%Y-%m-%d).log"

log_info "==== Backup run started ===="

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_PATH="${BACKUP_DEST}/backup_${TIMESTAMP}.tar.gz"

# --- Validate source directories ---
VALID_SOURCES=()
for src in "${SOURCE_DIRS[@]}"; do
    if [[ -e "$src" ]]; then
        VALID_SOURCES+=("$src")
    else
        log_warn "Source path does not exist, skipping: $src"
    fi
done

if [[ ${#VALID_SOURCES[@]} -eq 0 ]]; then
    log_error "No valid source directories found. Aborting."
    exit 1
fi

log_info "Creating archive: $ARCHIVE_PATH"
log_info "Sources: ${VALID_SOURCES[*]}"

if tar -czf "$ARCHIVE_PATH" "${VALID_SOURCES[@]}" 2>>"$LOG_FILE"; then
    SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
    log_info "Archive created successfully (${SIZE})"
else
    log_error "tar command failed. See $LOG_FILE for details."
    exit 1
fi

log_info "==== Backup run completed successfully ===="