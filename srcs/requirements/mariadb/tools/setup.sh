#!/bin/bash

# this script run in the building container
# it creates start the mariadb service and create the database and users according to the .env file
# at the end, exec $@ run the next CMD in the Dockerfile.
# In this case: "mysqld_safe" that restart the mariadb service


#DB_NAME=thedatabase
#DB_USER=theuser
#DB_PASSWORD=abc
#DB_PASS_ROOT=123

service mariadb start

#run commands from sql
mariadb -v -u root << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$DB_PASS_ROOT';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'root'@'%';
-- ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASS_ROOT';
EOF

sleep 15

service mariadb stop

exec $@
