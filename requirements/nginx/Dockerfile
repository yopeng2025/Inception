# lightweight# Dockerfile:
# how to start with a pure operating system, install software, configure the environment step by step

FROM debian:bullseye

RUN apt-get update && \                     # install NGINX
    apt-get install -y nginx openssl && \   # OpenSSL(Secure Sockets Layer(https)to generate encryption certificates)
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl                 # create dir for SSL certificates

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=yopeng.42.fr/UID=yopeng"
                                            # generate self-signed SSL certificate for enable HTTPS (TLS encryption; Transport Layer Security)
                                            # openssl req:    certificate request
                                            # -x509:  create self-signed certificate instead of a CSR(Certificate Signing Request)
                                            # -no-des: do not encrypt the private key (no passphrase required)
                                            # -out:   path to output certificate file
                                            # -keyout:path to output private key file
                                            # -subj:  provide certificate information directly
                                            # c(country) st(state) l(locality) o(organization) ou(organization unit) !cn(common name)!(if == domain name) uid(user id)

#COPY tools/localhost.pem     /etc/nginx/ssl/
#COPY tools/localhost-key.pem /etc/nginx/ssl/

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf 
                                            # copy configuration file from host to container


RUN mkdir -p /var/www/html && \              # create web root directory 
    chown -R www-data:www-data /var/www/html # change owner user_name:group_name -R(recursive, change all the subfolers & files)

EXPOSE 443                                  # expose the default nginx port

CMD ["nginx", "-g", "daemon off;"]          # run nginx daemon (global directives) in foreground(becoming PID1), instea of background
                                            # daemon process != background process, but it also runs in background
                                            # running foreground process = block background process
                                            # running background process = foreground process is allow to be run
                                            # `kill <PID>` == stop process
