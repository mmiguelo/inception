#!/bin/sh

# Download latest Adminer
echo "Downloading latest Adminer..."
wget -q "http://www.adminer.org/latest.php" -O /var/www/html/adminer.php

# Set permissions
chown -R www-data:www-data /var/www/html/adminer.php
chmod 755 /var/www/html/adminer.php

# Go to web directory
cd /var/www/html

# Remove default index if exists
rm -rf /var/www/html/index.html

echo "Starting PHP server on port 80..."
# Run PHP built-in server (exec to replace shell process)
exec php -S 0.0.0.0:80 -t /var/www/html
