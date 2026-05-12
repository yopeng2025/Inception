# Dockerfile:
# how to start with a pure operating system, install software, configure the environment step by step

FROM debian:bullseye                                             # base image for the container (stable version of Linux)

RUN apt-get update && \                                          # install MariaDB server and clean up cache
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf  # replace default file for the system with
                                                                 # the custom configuration file(conf/50-server.cnf)
                                                                 # which sets "bind-address = 0.0.0.0 (listen to internal inception-network)"

RUN mkdir -p /run/mysqld && \                                    # create socket file (for local communication)
    chown -R mysql:mysql /run/mysqld && \                        # change owner user_name:group_name -R(recursive, change all the subfolers & files)
    chown -R mysql:mysql /var/lib/mysql                          # give permission to user (not only root)to access socket and w&r persistent data

COPY tools/setup.sh /usr/local/bin/                              # standard location for Linux to store user-defined scripts
                                                                 # create a database name, set an administrator password, and create a dedicated database user for WordPress

RUN chmod +x /usr/local/bin/setup.sh                             # give permission to execute this script 

EXPOSE 3306                                                      # expose the default MariaDB port

ENTRYPOINT ["/usr/local/bin/setup.sh"]                           # Run container -> Execute setup.script

# MariaDB (mysql daemon) runs in foreground, therefore is it PID1 && main process