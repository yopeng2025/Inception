#!/bin/bash                                             # shebang, use /bin/bash executable to execute following codes
set -e                                                  # -e(exit on error), stop execution if any command fails

mkdir -p /run/php                                       # Create the directory for PHP runtime files(put PID, socket)
cd /var/www/html                                        # Move to the web root directory

# 1. Ensure WP-CLI is installed
if [ ! -f /usr/local/bin/wp ]; then                     # if -f(file) wp does not exist
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
                                                        # download wp-cli.phar  -O(remOte name)
    chmod +x wp-cli.phar                                # allow execute 
    mv wp-cli.phar /usr/local/bin/wp                    # move it to global binary directory (can type "wp" instead of whole path)
fi

# 2. Start configuration if wp-config.php does not exist
if [ ! -f wp-config.php ]; then                         # wp-config.php is CORE file
    echo "Configuring WordPress..."

    if [ ! -f index.php ]; then                         # Download WordPress CORE source files if index.php is missing
        wp core download --allow-root                   # By default, wp-cli does not allow run as root user
                                                        # But while initializing docker wp-cli need to run as root user 
                                                        # --allow-root: allow to run as root user
    fi

    until wp config create --allow-root \               # Create wp-config.php with following database credentials
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$SQL_PASSWORD" \
        --dbhost="mariadb:3306" --force; do             # --force: if file already exists, cover it with "mariabd:3306"
        echo "Waiting for MariaDB..."                   # until ...(mission), do (wait and try again), (as soon as mission is)done(finish!)
        sleep 2                                         # Robust!
    done

    wp core install --allow-root \                      # Install WordPress (finally!)
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_USER@42.fr"
else
    echo "WordPress already configured."
fi

chown -R www-data:www-data /var/www/html                # change owner user_name:group_name -R(recursive, change all the subfolers & files)

echo "Starting PHP-FPM..."

exec /usr/sbin/php-fpm7.4 -F                            # exec: execute                            
                                                        # PHP FastCGI Process Manager 
                                                        # -F: foreground mode == PID1