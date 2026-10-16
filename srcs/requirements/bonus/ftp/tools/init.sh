#!/bin/bash

set -e

FTP_USER="ftpuser"

echo "Starting FTP initialization..."

if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "Creating FTP user..."

    useradd \
        --home-dir "/var/www/html" \
        --shell /bin/bash \
        "$FTP_USER"
fi

echo "Setting FTP password..."

FTP_PASSWORD="$(cat /run/secrets/ftp_password)"
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

echo "Preparing FTP user..."

# Give ftpuser access to the WordPress files through the www-data group.
usermod -aG www-data "$FTP_USER"

# Make sure the WordPress files are accessible by the www-data group.
chown -R www-data:www-data /var/www/html
chmod -R g+rwX /var/www/html
usermod -d /var/www/html ftpuser

echo "Starting vsftpd..."

exec /usr/sbin/vsftpd /etc/vsftpd.conf
