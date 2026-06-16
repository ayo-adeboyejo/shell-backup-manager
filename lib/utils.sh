#!/usr/bin/env bash
#
# utils.sh - Logging and notification helpers
#
# Expects $LOG_FILE to be set by the caller before these functions are used.

log_info()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $*" | tee -a "$LOG_FILE"; }
log_warn()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]  $*" | tee -a "$LOG_FILE" >&2; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" | tee -a "$LOG_FILE" >&2; }

# notify <STATUS> <MESSAGE>
#
# Sends an email notification if NOTIFY_EMAIL is configured in backup.conf.
notify() {
    local status="$1"
    local message="$2"

    if [[ -n "${NOTIFY_EMAIL:-}" ]] && command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "Backup $status: $(hostname)" "$NOTIFY_EMAIL" \
            || log_warn "Failed to send email notification."
    fi
}