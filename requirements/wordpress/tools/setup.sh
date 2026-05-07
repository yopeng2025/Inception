#!/bin/bash
set -e

mkdir -p /run/php
cd /var/www/html

# 1. 确保 WP-CLI 存在
if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# 2. 【核心修改】只要目录下没有 wp-config.php，我们就开始配置
if [ ! -f wp-config.php ]; then
    echo "Configuring WordPress..."

    # 如果目录下没有 index.php (说明源码都没下载)，才执行 download
    if [ ! -f index.php ]; then
        wp core download --allow-root
    fi

    # 创建 wp-config.php
    # 如果这一步报错，说明 MariaDB 还没准备好，我们加一个重试逻辑
    until wp config create --allow-root \
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$SQL_PASSWORD" \
        --dbhost="mariadb:3306" --force; do
        echo "Waiting for MariaDB..."
        sleep 2
    done

    # 执行安装
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_USER@42.fr"
else
    echo "WordPress already configured."
fi

chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."

# PHP FastCGI Process Manager 
# -F: foreground mode == PID1
# exec: execute
exec /usr/sbin/php-fpm7.4 -F