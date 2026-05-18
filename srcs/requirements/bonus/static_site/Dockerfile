FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx &&\
    rm -rf /var/lib/apt/lists/*

# copy my static site to Nginx's default directory
COPY index.html /var/www/html/index.html

# change Nginx configuration:
#   listen port 80
#   run in foreground
RUN echo "server { \
    listen 80; \
    root /var/www/html; \
    index index.html; \
    location / { \
        try_files \$uri \$uri/ =404; \
    } \
}" > /etc/nginx/sites-available/default

EXPOSE 80

# run Nginx; make sure PID1 keeps running 
CMD ["nginx", "-g", "daemon off;"]

# https://yopeng.42.fr/static
# configure in nginx.conf