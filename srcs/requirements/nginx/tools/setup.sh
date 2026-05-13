#!/bin/bash

# Stop the script if any command fails; -e(exit on error)
set -e

# 1. Ensure the SSL directory exists
# This path must match 'ssl_certificate' in nginx.conf
if [ ! -d "/etc/nginx/ssl" ]; then
    echo "Creating SSL directory..."
    mkdir -p /etc/nginx/ssl
fi

# 2. Generate a self-signed SSL certificate and private key
# Only generate if the certificate doesn't already exist to avoid overwriting
if [ ! -f "/etc/nginx/ssl/inception.crt" ]; then
    echo "Generating SSL certificate for $DOMAIN_NAME..."
    
    # req: Certificate request and generation utility
    # -x509: Outputs a self-signed certificate instead of a request
    # -nodes: No DES (do not encrypt the private key, so Nginx can start without a password)
    # -days 365: certificate validity period (expire in 356 days)
    # -newkey rsa:2048: Generate a new 2048-bit RSA key
    # -keyout: Path to save the private key
    # -out: Path to save the certificate
    # -subj: Pre-fills certificate identity information 
    #        (Country, State, Locality, Organization, Organization Unit, Common Name, User ID)
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=$DOMAIN_NAME/UID=yopeng"
    
    echo "SSL certificate successfully generated."
fi

# 3. Start Nginx in the foreground
# -g "daemon off;": Prevents Nginx from running as a background daemon.
# In Docker, the main process (PID 1) must stay in the foreground to keep the container running.
# 'exec' replaces the shell with the nginx process.
echo "Starting Nginx..."
exec nginx -g "daemon off;"