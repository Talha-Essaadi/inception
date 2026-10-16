#!/bin/bash

set -e

if [ ! -f /etc/nginx/ssl/tessaadi.42.fr.crt ]; then
    echo "Generating TLS certificate..."

    openssl req -x509 \
        -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/tessaadi.42.fr.key \
        -out /etc/nginx/ssl/tessaadi.42.fr.crt \
        -subj "/C=MA/ST=Marrakech/L=Benguerir/O=42/OU=Student/CN=tessaadi.42.fr"
fi

echo "Starting NGINX..."

exec nginx -g "daemon off;"