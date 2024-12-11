#!/bin/bash

set -e

# Проверяем, существует ли системная база данных MariaDB
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    
    # Устанавливаем владельца и права для MariaDB
    chown -R mysql:mysql /var/lib/mysql
    chmod 750 /var/lib/mysql

    # Инициализация базы данных
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --basedir=/usr

    echo "Database initialized."
fi

# Проверяем, создана ли пользовательская база данных
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Setting up initial database..."

    # Создаём временный SQL файл
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

    # Запускаем MariaDB в безопасном режиме и применяем SQL
    mysqld --user=mysql --bootstrap < /tmp/create_db.sql
    rm -f /tmp/create_db.sql

    echo "Initial database setup complete."
fi

# Запускаем MariaDB
exec mysqld --user=mysql