#!/bin/bash

set -e

# Initialize database only on first run
if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "Initializing MariaDB..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "Starting temporary MariaDB..."

    mariadbd \
        --user=mysql \
        --skip-networking \
        --socket=/run/mysqld/mysqld.sock \
        --datadir=/var/lib/mysql &

    echo "Waiting for MariaDB..."

    until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent; do
        sleep 1
    done

    echo "Creating database and users..."

    mysql --socket=/run/mysqld/mysqld.sock <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';

FLUSH PRIVILEGES;
EOF

    echo "Stopping temporary MariaDB..."

    mysqladmin \
        --socket=/run/mysqld/mysqld.sock \
        -uroot \
        -p"${MYSQL_ROOT_PASSWORD}" shutdown

fi

echo "Starting MariaDB..."

exec mariadbd \
    --user=mysql \
    --bind-address=0.0.0.0 \
    --datadir=/var/lib/mysql