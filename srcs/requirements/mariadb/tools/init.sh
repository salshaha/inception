#!/bin/bash

set -e

# Initialize the database only on the first run
if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "Initializing MariaDB..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "Starting temporary MariaDB..."

    mysqld_safe --datadir=/var/lib/mysql &

    echo "Waiting for MariaDB..."

    until mysqladmin ping --silent; do
        sleep 1
    done

    echo "Creating database and user..."

    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "Stopping temporary MariaDB..."

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

fi

echo "Starting MariaDB..."

exec mysqld_safe --datadir=/var/lib/mysql
