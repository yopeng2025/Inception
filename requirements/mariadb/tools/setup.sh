#!/bin/bash
set -e

# 确保运行时目录存在
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# 初始化数据库目录（如果没初始化过）
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# 以后台模式启动 MySQL 以进行初始化设置
mysqld_safe --datadir=/var/lib/mysql &

# 等待 MySQL 启动完毕
until mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

# 执行初始化 SQL
if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Initializing database..."
    
    # 1. 创建数据库
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    
    # 2. 创建用户并授权（关键：统一使用 '%' 允许外部连接）
    # 注意：在 GRANT 语句中直接指定 IDENTIFIED BY 会同时创建用户
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    
    # 3. 修改 root 密码
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    
    # 4. 刷新权限
    mysql -e "FLUSH PRIVILEGES;"
    
    echo "Database initialized successfully."
fi

# 关闭后台进程，准备通过 exec 启动前台进程
mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

# 使用 exec 启动前台进程，确保它是容器内的 PID 1
echo "Starting MariaDB in foreground..."
exec mysqld_safe --datadir=/var/lib/mysql
