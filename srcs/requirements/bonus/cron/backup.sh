#!/bin/bash

# Backup script for WordPress database and files
# This script is executed by cron

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "[$DATE] Starting backup..."

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup MariaDB database
echo "[$DATE] Backing up database..."
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_DIR/db_backup_$DATE.sql"

if [ $? -eq 0 ]; then
    echo "[$DATE] Database backup completed: db_backup_$DATE.sql"
else
    echo "[$DATE] Database backup FAILED!"
fi

# Backup WordPress files (only wp-content for user data)
echo "[$DATE] Backing up WordPress files..."
tar -czf "$BACKUP_DIR/wp_files_$DATE.tar.gz" -C /var/www/inception wp-content 2>/dev/null

if [ $? -eq 0 ]; then
    echo "[$DATE] WordPress files backup completed: wp_files_$DATE.tar.gz"
else
    echo "[$DATE] WordPress files backup FAILED or no wp-content found!"
fi

# Clean up old backups (keep last 7 days)
echo "[$DATE] Cleaning up old backups..."
find "$BACKUP_DIR" -name "db_backup_*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "wp_files_*.tar.gz" -mtime +7 -delete

echo "[$DATE] Backup process completed!"
