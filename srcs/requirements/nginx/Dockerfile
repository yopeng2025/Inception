# Dockerfile:
# how to start with a pure operating system, install software, configure the environment step by step

# Debian Stable = Bookworm(12)latest version 
#               & Bullseye(11)last but second version
FROM debian:bullseye

# install NGINX
#         OpenSSL(Secure Sockets Layer(https)to generate encryption certificates)
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# copy configuration file from host to container
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the setup script and make it executable
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# create web root directory
# change owner user_name:group_name -R(recursive, change all the subfolers & files)
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# expose the default nginx port
EXPOSE 443

# run nginx daemon (global directives) in foreground(becoming PID1), instea of background
# daemon process != background process, but it also runs in background
# running foreground process = block background process
# running background process = foreground process is allow to be run
# `kill <PID>` == stop process
# CMD ["nginx", "-g", "daemon off;"]

ENTRYPOINT ["/usr/local/bin/setup.sh"]