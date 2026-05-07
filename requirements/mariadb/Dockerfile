FROM debian:bullseye

# Install MariaDB server and clean up cache
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy the custom configuration file
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Create required directories and set permissions
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

# Copy the setup script and make it executable
COPY tools/setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup.sh

# Expose the default MariaDB port
EXPOSE 3306

# Run the setup script
ENTRYPOINT ["/usr/local/bin/setup.sh"]

# MariaDB (mysql daemon) runs in foreground, therefore is it PID1 && main process