# Dockerfile:
# how to start with a pure operating system, install software, configure the environment step by step

FROM debian:bullseye

# Install PHP env(php php-fpm php-cli) databasesupport(php-mysql mariadb-client) Curl(download wp-cli)
# PHP FastCGI Process Manager 
# download PHP Redis extension
# clean up cache
RUN apt-get update && \
    apt-get install -y php php-cli php-fpm php-mysql curl mariadb-client && \
    apt-get install -y php-redis && \
    rm -rf /var/lib/apt/lists/*

# replace default file for the system with
# the custom configuration file(conf/www.cnf)
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# standard location for Linux to store user-defined scripts
COPY tools/setup.sh /usr/local/bin/

# give permission to execute this script
RUN chmod +x /usr/local/bin/setup.sh

# expose port 9000 for NGINX
EXPOSE 9000

# run the setup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/setup.sh"]
