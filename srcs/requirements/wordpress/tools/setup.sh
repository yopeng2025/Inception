#!/bin/bash
set -e
# -e(exit on error), stop execution if any command fails

# Create the directory for PHP runtime files(put PID, socket)
mkdir -p /run/php
# Move to the web root directory
cd /var/www/html

# 1. Ensure WP-CLI is installed
# if -f(file) wp does not exist
# download wp-cli.phar  -O(remOte name)
# allow execute 
# move it to global binary directory (can type "wp" instead of whole path)
if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# 2. Start configuration if wp-config.php does not exist
# wp-config.php is CORE file
if [ ! -f wp-config.php ]; then
    echo "Configuring WordPress..."

    # Download WordPress CORE source files if index.php is missing
    # By default, wp-cli does not allow run as root user
    # But while initializing docker wp-cli need to run as root user 
    # --allow-root: allow to run as root user
    if [ ! -f index.php ]; then
        wp core download --allow-root
    fi

    # Create wp-config.php with following database credentials 
    # --force: if file already exists, cover it with "mariadb:3306"
    # until ...(mission), do (wait and try again), (as soon as mission is)done(finish!)
    until wp config create --allow-root \
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$SQL_PASSWORD" \
        --dbhost="mariadb:3306" --force; do
        echo "Waiting for MariaDB..."
        sleep 2
    done

    # Install WordPress (create admin user)
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_USER@42.fr"

    # (create 2nd user as author) 
    wp user create --allow-root \
        "$WP_USER" "$WP_USER@42.fr" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author

else
    echo "WordPress already configured."
fi

# change owner user_name:group_name -R(recursive, change all the subfolers & files)
chown -R www-data:www-data /var/www/html

# exec: execute
# PHP FastCGI Process Manager 
# -F: foreground mode == PID1
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F