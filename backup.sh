#!/usr/bin/env bash
#
# backup.sh - config-driven backup script with dry-run support
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/backup.conf"
DRY_RUN=false

source "${SCRIPT_DIR}/lib/utils.sh"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -c, --config FILE   Use an alternate config file (default: config/backup.conf)
  -n, --dry-run       Show what would be done without making any changes
  -h, --help          Show this help message and exit
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

source "$CONFIG_FILE"

LOG_DIR="${LOG_DIR:-${SCRIPT_DIR}/logs}"
mkdir -p "$BACKUP_DEST" "$LOG_DIR"
LOG_FILE="${LOG_DIR}/backup_$(date +%Y-%m-%d).log"

log_info "==== Backup run started ===="
[[ "$DRY_RUN" == true ]] && log_info "Running in DRY-RUN mode. No changes will be made."

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_PATH="${BACKUP_DEST}/backup_${TIMESTAMP}.tar.gz"


# loop through the sources to confirm their validity and save them in an array
VALID_SOURCES=()
for src in "${SOURCE_DIRS[@]}"; do
    if [[ -e "$src" ]]; then
        VALID_SOURCES+=("$src")
    else
        log_warn "Source path does not exist, skipping: $src"
    fi
done

# 
if [[ ${#VALID_SOURCES[@]} -eq 0 ]]; then
    log_error "No valid source directories found. Aborting."
    exit 1
fi

log_info "Creating archive: $ARCHIVE_PATH"
log_info "Sources: ${VALID_SOURCES[*]}"

if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would run: tar -czf $ARCHIVE_PATH ${VALID_SOURCES[*]}"
else
    if tar -czf "$ARCHIVE_PATH" "${VALID_SOURCES[@]}" 2>>"$LOG_FILE"; then
        SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
        log_info "Archive created successfully (${SIZE})"
    else
        log_error "tar command failed. See $LOG_FILE for details."
        exit 1
    fi
fi

log_info "==== Backup run completed successfully ===="