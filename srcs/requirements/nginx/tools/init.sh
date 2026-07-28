#!/bin/bash

set -e

echo "Creating SSL directory..."

mkdir -p /etc/nginx/ssl

echo "Generating SSL certificate..."

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=JO/ST=Amman/L=Amman/O=42/CN=${DOMAIN_NAME}"

echo "Starting NGINX..."

exec nginx -g "daemon off;"