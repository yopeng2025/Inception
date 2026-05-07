# lightweight
FROM debian:bullseye

# Install NGINX, OpenSSL(Secure Sockets Layer(https)：to generate encryption certificates), and clean up cache to save space
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# create dir for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# generate self-signed SSL certificate for HTTPS
# req:    request
# -x509:  create self-signed certificate
# -nodes: do not encrypt the private key
# -subj:  provide certificate information directly
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=yopeng.42.fr/UID=yopeng"

COPY tools/localhost.pem /etc/nginx/ssl/
COPY tools/localhost-key.pem /etc/nginx/ssl/

# copy configuration file from Host to Container
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# IMPORTANT: Create the web root directory and set permissions
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

EXPOSE 443

# run nginx daemon (global directives) in foreground(becoming PID1), instea of background
# daemon process != background process, but it also runs in background
# running foreground process = block background process
# running background process = foreground process is allow to be run
# `kill <PID>` == stop process
CMD ["nginx", "-g", "daemon off;"]
