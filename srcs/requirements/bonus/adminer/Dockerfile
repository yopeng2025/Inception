FROM debian:bullseye

# download php-mysqli (MySQL Driver) 
#          php-curl (http request extension)
#          php-gd (Graphics Draw)
#          php-xml (eXtensible Markup Language)
#          php-mbstring (MultiByte String) 
#          (handle Chinese, Unicode and various non-English characters to avoid garbled and truncated errors)
#          wget (web get) download files
RUN apt-get update && \
    apt-get install -y php php-mysqli php-curl php-gd php-xml php-mbstring wget && \
    rm -rf /var/lib/apt/lists/*

# the following command will be executed in this directory 
# = cd /var/www/html
WORKDIR /var/www/html

# download adminer with output name "index.php"
RUN wget "https://www.adminer.org/latest.php" -O index.php

RUN chown -R www-data:www-data /var/www/html

EXPOSE 8080

# the next command does not need root to execute
# if the programme is being attacked, the attacker only get the permission of user but not root
USER www-data

# run php server
# -S server
# 0.0.0.0:8080 allow external connection & 8080
# index.php: deal with requests
# When the container starts, listen for port 8080 with PHP(web server) 
# and provides website services via index.php
CMD ["php", "-S", "0.0.0.0:8080", "index.php"]