#!/bin/bash

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    
    chown -R mysql:mysql /var/lib/mysql
    chmod 750 /var/lib/mysql

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --basedir=/usr

    echo "Database initialized."
fi

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Setting up initial database..."

    cat << EOF > /tmp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE \`${MYSQL_DATABASE}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    mysqld --user=mysql --bootstrap < /tmp/create_db.sql
    rm -f /tmp/create_db.sql

    echo "Initial database setup complete."
fi

exec mysqld --user=mysql
