# shell-backup-manager

A lightweight, cron-friendly Bash tool for automated backups with day-based retention cleanup and email alerts.

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=flat&logo=gnu-bash&logoColor=white)
![Cron](https://img.shields.io/badge/Scheduling-cron-blue?style=flat)
![License](https://img.shields.io/badge/license-MIT-green)


## Problem Statement

As a system administrator, backing up directories, log files, and configs is part of my day-to-day. I used to handle it the way most sysadmins start out — a quick cron job here, a one-off tar command there. It worked, until it didn't. Old archives piled up silently and ate disk space I only noticed when a server warned me it was nearly full. A failed backup once went unnoticed for weeks because nothing told me it had failed. And more than once I worried about two cron runs overlapping on a slow night, with no safeguard in place to stop it.

I built shell-backup-manager to fix that, for good. Instead of another one-off script, I wanted something I could point at any directory, configure once, and trust to run unattended — archiving, cleaning up old backups, and notifying me if anything went wrong, all from a single script.

## Tech Stack

- Bash (4+)
- Core Unix utilities: tar, find, flock, date
- mail command for email notifications (optional)
- cron for scheduling

## Features

- Config-driven setup — define sources, destination, and retention in one file
- Automatic retention cleanup — deletes backups older than N days (or never, if disabled)
- Email notifications on success and failure
- Dry-run mode to preview actions before they run for real
- Lock-file protection against overlapping runs
- Timestamped daily logs

## How to Run Locally

1. Clone the repo:

       git clone https://github.com/ayo-adeboyejo/shell-backup-manager.git
       cd shell-backup-manager

2. Make the script executable:

       chmod +x backup.sh

3. Edit config/backup.conf with your own paths:

       SOURCE_DIRS=("/home/user/documents" "/etc/myapp")
       BACKUP_DEST="/var/backups/myapp"
       RETENTION_DAYS=7        # leave empty ("") to disable auto-deletion
       NOTIFY_EMAIL=""         # optional, requires 'mail' command

4. Run a dry run first to confirm it does what you expect:

       ./backup.sh -n

5. Run it for real:

       ./backup.sh

6. (Optional) Schedule it nightly with cron:

       0 2 * * * /path/to/shell-backup-manager/backup.sh >> /path/to/shell-backup-manager/logs/cron.log 2>&1

## Folder Structure

    shell-backup-manager/
    ├── backup.sh           # main script — parses args, runs the backup, triggers cleanup/notify
    ├── config/
    │   └── backup.conf     # user-editable settings (sources, destination, retention, email)
    ├── lib/
    │   └── utils.sh         # logging helpers (log_info/log_warn/log_error) and notify()
    ├── logs/                # daily log files, generated at runtime

## Learnings / Challenges

- stdout vs. stderr — routing log_warn/log_error to stderr (via >&2) while keeping log_info on stdout took some thought, but it matters for cron: cron's default mail-on-error behavior is triggered by stderr output, so keeping that separation meant failures could be caught two ways (the script's own notify() and cron's built-in alerting).
- Preventing overlapping runs — added flock on a lock file after realizing a slow backup (e.g., a large directory) could overlap with the next scheduled cron run and corrupt an in-progress archive.
- Sourcing vs. executing — using source to pull in lib/utils.sh rather than running it as a separate script was key to letting helper functions share state (like $LOG_FILE) with the main script without passing everything explicitly.

## Contact

- LinkedIn: https://www.linkedin.com/in/ayodejiadeboyejo/
- Email: ae.adeboyejo@gmail.com