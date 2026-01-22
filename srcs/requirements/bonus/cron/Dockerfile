# Cron - Scheduled backup service for WordPress and MariaDB
# Performs regular backups of database and files

FROM    debian:bookworm

# Install cron and mariadb-client for database backups
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        cron \
        mariadb-client && \
        rm -rf /var/lib/apt/lists/*

# Create backup directory
RUN     mkdir -p /backups

# Copy crontab file
COPY    crontab /etc/cron.d/backup-cron

# Copy backup script
COPY    backup.sh /usr/local/bin/backup.sh

# Set permissions
RUN     chmod 0644 /etc/cron.d/backup-cron && \
        chmod +x /usr/local/bin/backup.sh && \
        crontab /etc/cron.d/backup-cron

# Create log file for cron
RUN     touch /var/log/cron.log

# Run cron in foreground and tail the log
CMD     ["cron", "-f"]
