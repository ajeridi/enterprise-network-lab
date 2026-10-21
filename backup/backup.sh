#!/bin/bash
# Backup of the website files on the Ubuntu web server (DMZ).
# Usage:
#   backup.sh full   -> full backup (run every Monday by cron)
#   backup.sh        -> incremental backup (run the other days)

# Directory to back up
backup_files="${BACKUP_SOURCE:-/var/www/html}"

# Destination directory
dest="${BACKUP_DEST:-/home/ubuntu/backup}"

# Archive name: date and time, so that two runs on the same day do not overwrite each other
day=$(date "+%Y-%m-%d")
archive_name="backup_$(date "+%Y-%m-%d_%H-%M").tar.gz"

# Snapshot file (.snar): metadata of the last backup, used by tar for incremental backups
snapshot="$dest/last_backup.snar"

mkdir -p "$dest"

if [ "$1" = "full" ]; then
    # Weekly full backup: deleting the snapshot forces tar to save everything
    path="$dest/full_$archive_name"
    rm -f "$snapshot"
else
    # Incremental backup: only the files changed since the last backup
    path="$dest/incr_$archive_name"
fi

echo "Backing up $backup_files to $path"
tar -czf "$path" --listed-incremental="$snapshot" "$backup_files"
backup_ok=$?

if [ "$backup_ok" -eq 0 ]; then
    # Only a successful backup becomes "latest": the Windows server always fetches a valid archive
    ln -snf "$path" "$dest/latest"
    log_message="Backup to $path successful"
else
    # Remove the incomplete archive; "latest" still points to the last valid backup
    rm -f "$path"
    log_message="Backup to $path not successful (tar exit code $backup_ok)"
fi

# Add to the log
time=$(date "+%T")
echo "$log_message"
echo "$day $time $log_message" >> "$dest/backup_log.txt"

# Return tar's exit code, so that cron or a monitoring tool can see the failure
exit "$backup_ok"
