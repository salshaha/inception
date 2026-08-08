#!/bin/bash

set -e

cd /var/www/html

echo "Waiting for MariaDB..."

until mysql \
    -h mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    -e "SELECT 1;" >/dev/null 2>&1
do
    sleep 2
done

echo "MariaDB is ready!"


if [ ! -f "wp-config.php" ]; then

    echo "Checking WordPress files..."

    if [ ! -d "wp-includes" ]; then
        echo "Downloading WordPress..."
        wp core download --allow-root
    else
        echo "WordPress files already exist."
    fi


    echo "Creating wp-config.php..."

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root


    echo "Installing WordPress..."

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

else

    echo "WordPress already configured."

fi


echo "Starting PHP-FPM..."

php-fpm8.2 -F