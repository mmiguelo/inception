#!/bin/bash

# Create FTP user if it doesn't exist
if ! id "$FTP_USER" &>/dev/null; then
    echo "Creating FTP user: $FTP_USER"
    # 'useradd' creates a new user with:
    # - '-m' to create the user's home directory
    # - '-d' to specify the home directory path as /var/www/inception
    # This creates the FTP user with the specified directory for their files.
    useradd -m -d /var/www/inception "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    # Set the ownership of the directory /var/www/inception to the FTP user
    # '-R' means recursive, so all files and subdirectories will have their ownership changed
    chown -R "$FTP_USER:$FTP_USER" /var/www/inception
fi

echo "Starting vsftpd server..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf