# Dockerfile:
# how to start with a pure operating system, install software, configure the environment step by step

FROM debian:bullseye                        # base image for the container (stable version of Linux)

RUN apt-get update && \                     # Install PHP env(php php-fpm php-cli) databasesupport(php-mysql mariadb-client) Curl
    apt-get install -y php php-cli php-fpm php-mysql curl mariadb-client && \
    rm -rf /var/lib/apt/lists/*             # clean up cache

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
                                            # replace default file for the system with
                                            # the custom configuration file(conf/www.cnf)

COPY tools/setup.sh /usr/local/bin/         # standard location for Linux to store user-defined scripts
RUN chmod +x /usr/local/bin/setup.sh        # give permission to execute this script 

EXPOSE 9000                                 # expose port 9000 for NGINX

ENTRYPOINT ["/usr/local/bin/setup.sh"]      # run the setup script as the entrypoint
