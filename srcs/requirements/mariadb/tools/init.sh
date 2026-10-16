#!/bin/bash

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

# Initialize MariaDB system tables if necessary
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB system tables..."

    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql
fi

echo "Starting MariaDB..."

mysqld --user=mysql &

pid="$!"

echo "Waiting for MariaDB..."

until mariadb-admin \
    -h localhost \
    ping --silent
do
    sleep 1
done

echo "MariaDB is ready."

# Check whether the WordPress database exists
DATABASE_EXISTS=$(mariadb \
    -h localhost \
    -u root \
    -p"${MYSQL_ROOT_PASSWORD}" \
    -N \
    -B \
    -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${MYSQL_DATABASE}';")


echo "DATABASE check >>"

if [ -z "$DATABASE_EXISTS" ]; then

    echo "Creating WordPress database and user..."

    mariadb \
        -h localhost \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        <<EOF

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

EOF

    echo "Database initialization complete."

else

    echo "MariaDB data already exists."
fi

echo "MariaDB is running."

mysqladmin -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
wait "$pid"

echo "restart mariadb"
exec mysqld --user=mysql