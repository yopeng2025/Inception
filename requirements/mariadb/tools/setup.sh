# setup shell script:
# Configure the account password at the first start, and then run directly next time.

#!/bin/bash                                                 # shebang, use /bin/bash executable to execute following codes
set -e                                                      # -e(exit on error), stop execution if any command fails

mkdir -p /run/mysqld                                        # Ensure the runtime directory exists for the MySQL socket file
chown -R mysql:mysql /run/mysqld                            # change owner user_name:group_name -R(recursive, change all the subfolers & files)

if [ ! -d "/var/lib/mysql/mysql" ]; then                    # Initialize the database data directory if it's empty
    mysql_install_db --user=mysql --datadir=/var/lib/mysql  # -d(if it is a directory) !(if not/not exist)
                                                            # execute mysql_install_db (install database)
                                                            # 1. create dir "/var/lib/mysql/mysql"
                                                            # 2. change owner to mysql user
fi

mysqld_safe --datadir=/var/lib/mysql &                      # Start MariaDB in the background to perform initial configuration
                                                            # mysqld_safe: Secure startup script  &:run in background(allow script execution)

until mysqladmin ping >/dev/null 2>&1; do                   # check ping each 1s & print message untill MariaDB is fully started and responsive
    echo "Waiting for MariaDB to start..."                  # /dev/null (discard normal output) 2>&1 (discard error output)
    sleep 1
done

# Initialize SQL
if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Initializing database..."
    
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"  # 1. Create the database specified in the .env file
                                                                   #    mysql: command line -e:execute
                                                                   #    SQL syntax "create database": literally means create database
                                                                   #               "if not exists":   literally
                                                                   #    ${SQL_DATABASE}： will be replaced by the variable in .env (`backtick`--database name)

    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
                                                                   # 2. Create the user & grand all privileges with password
                                                                   #    SQL syntax "GRANT ALL PRIVILEGES": allow user totally control this database
                                                                   #    "ON inception.*" : *all tables in database 
                                                                   #    "TO yopeng@'%'" : allow connection from all IP
                                                                   #    "IDENTIFIED BY 'pass_word' " : set password to this user

    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
                                                                   # 3. Secure the root account with a password
                                                                   #    "ALTER USER": edit existed user information
                                                                   #    'root'@'localhost': user name (e.g. yopeng@localhost)
                                                                   #    "IDENTIFIED BY 'root_password'": set user password as root_password
    mysql -e "FLUSH PRIVILEGES;"                                   # 4. Apply changes immediately
    
    echo "Database initialized successfully."
fi

mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown          # Shutdown the background temporary process
                                                            # mysqladmin: command line tool
                                                            # -u root: root user
                                                            # -p123456: give password
                                                            # shutdown: stop elegantly & safely 
echo "Starting MariaDB in foreground..."

exec mysqld_safe --datadir=/var/lib/mysql                   # Use 'exec' to start MariaDB in the foreground as PID 1
                                                            # ensures the container keeps running as long as the database is alive
                                                            # mysqld_safe: Secure startup script