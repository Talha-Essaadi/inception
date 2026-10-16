#!/bin/bash

set -e

WORDPRESS_DIR="/var/www/html"


echo "Starting WordPress initialization..."

# Read the database password from Docker secret
MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

# --------------------------------------------------
# 1. Download WordPress
# --------------------------------------------------

if [ ! -f "$WORDPRESS_DIR/wp-load.php" ]; then

    echo "WordPress files not found. Downloading..."

    curl -fsSL https://wordpress.org/latest.tar.gz \
        -o /tmp/wordpress.tar.gz

    tar -xzf /tmp/wordpress.tar.gz \
        --strip-components=1 \
        -C "$WORDPRESS_DIR"

    rm -f /tmp/wordpress.tar.gz

fi


# --------------------------------------------------
# 2. Set permissions
# --------------------------------------------------

chown -R www-data:www-data "$WORDPRESS_DIR"


# --------------------------------------------------
# 3. Wait for MariaDB
# --------------------------------------------------

echo "Waiting for MariaDB..."

until mariadb \
    -h"$MYSQL_HOST" \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    -e "SELECT 1;" >/dev/null 2>&1
do
    sleep 2
done

echo "MariaDB is ready."


# --------------------------------------------------
# 4. Create wp-config.php
# --------------------------------------------------

if [ ! -f "$WORDPRESS_DIR/wp-config.php" ]; then

    echo "Creating wp-config.php..."

    wp --allow-root config create \
        --path="$WORDPRESS_DIR" \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --skip-check

    echo "wp-config.php created."

fi


# --------------------------------------------------
# 5. Install WordPress
# --------------------------------------------------

if ! wp --allow-root  core is-installed --path="$WORDPRESS_DIR" 2>/dev/null; then

    echo "Installing WordPress..."

    wp --allow-root  core install \
        --path="$WORDPRESS_DIR" \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email

    echo "WordPress installation completed."

else

    echo "WordPress is already installed."

fi




# --------------------------------------------------
# 6. Make sure WordPress files belong to www-data
# --------------------------------------------------

chown -R www-data:www-data "$WORDPRESS_DIR"


# --------------------------------------------------
# 7. Install & setup redis extension
# --------------------------------------------------

rm -rf /var/www/html/wp-content/object-cache.php
wp plugin --allow-root  --path="$WORDPRESS_DIR" delete --all


if ! wp plugin is-installed redis-cache --allow-root --path="$WORDPRESS_DIR"; then
    wp plugin install redis-cache --allow-root --path="$WORDPRESS_DIR"
fi


if ! wp plugin is-active redis-cache --allow-root --path="$WORDPRESS_DIR"; then
    wp plugin activate redis-cache --allow-root --path="$WORDPRESS_DIR"
fi


wp config set WP_REDIS_HOST "$WP_REDIS_HOST" \
    --type=constant \
    --path="$WORDPRESS_DIR" \
    --allow-root

wp config set WP_REDIS_PORT "$WP_REDIS_PORT" \
    --raw \
    --type=constant \
    --path="$WORDPRESS_DIR" \
    --allow-root


wp redis enable --allow-root --path="$WORDPRESS_DIR"

# --------------------------------------------------
# 8. Activate theme
# --------------------------------------------------

if ! wp theme is-active twentytwentyfour --allow-root --path="$WORDPRESS_DIR"; then
    wp theme activate twentytwentyfour --allow-root --path="$WORDPRESS_DIR"
fi


if ! wp user get "$WP_EDITOR_USER" --field=ID --allow-root --path="$WORDPRESS_DIR" >/dev/null 2>&1; then
    wp user create "$WP_EDITOR_USER" "$WP_EDITOR_EMAIL" \
        --role=editor \
        --user_pass="$WP_USER_PASSWORD" \
        --path="$WORDPRESS_DIR" \
        --allow-root
fi
# --------------------------------------------------
# 9. Start PHP-FPM
# --------------------------------------------------

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F
