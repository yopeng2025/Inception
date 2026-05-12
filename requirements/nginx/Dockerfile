# lightweight# Dockerfile:
# how to start with a pure operating system, install software, configure the environment step by step

FROM debian:bullseye

# install NGINX
# OpenSSL(Secure Sockets Layer(https)to generate encryption certificates)
RUN apt-get update && \                     
    apt-get install -y nginx openssl && \   
    rm -rf /var/lib/apt/lists/*

# create dir for SSL certificates
RUN mkdir -p /etc/nginx/ssl                 

# generate self-signed SSL certificate for enable HTTPS (TLS encryption; Transport Layer Security)
# openssl req:    certificate request
# -x509:  create self-signed certificate instead of a CSR(Certificate Signing Request)
# -no-des: do not encrypt the private key (no passphrase required)
# -out:   path to output certificate file
# -keyout:path to output private key file
# -subj:  provide certificate information directly
# c(country) st(state) l(locality) o(organization) ou(organization unit) !cn(common name)!(if == domain name) uid(user id)
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=yopeng.42.fr/UID=yopeng"

# copy configuration file from host to container
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf 

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
CMD ["nginx", "-g", "daemon off;"]
