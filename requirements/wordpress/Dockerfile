# Use Debian Bullseye as the base image
FROM debian:bullseye

# Install PHP, PHP-FPM, PHP-MySQL, and Curl
RUN apt-get update && \
    apt-get install -y php php-cli php-fpm php-mysql curl mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Copy our PHP-FPM configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copy the setup script
COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# Expose port 9000 for NGINX
EXPOSE 9000

# Run the setup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/setup.sh"]
