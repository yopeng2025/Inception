# Dockerfile:
# how to start with a pure operating system, install software, configure the environment step by step

FROM debian:bullseye

# install MariaDB server and clean up cache
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# replace default file for the system with
# the custom configuration file(conf/50-server.cnf)
# which sets "bind-address = 0.0.0.0 (listen to internal inception-network)"
#                       if = 127.0.0.1 (wordpress cannot connect to database)   
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# create socket file (for local communication)
# change owner user_name:group_name -R(recursive, change all the subfolers & files)
# give permission to user (not only root)to access socket and w&r persistent data
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

# standard location for Linux to store user-defined scripts
# create a database name, set an administrator password, and create a dedicated database user for WordPress
COPY tools/setup.sh /usr/local/bin/

# give permission to execute this script
RUN chmod +x /usr/local/bin/setup.sh

# expose the default MariaDB port
EXPOSE 3306

# Run container -> Execute setup.script
ENTRYPOINT ["/usr/local/bin/setup.sh"]

# MariaDB (mysql daemon) runs in foreground, therefore is it PID1 && main process