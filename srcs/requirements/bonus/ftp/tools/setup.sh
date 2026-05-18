#!/bin/bash
set -e

mkdir -p /var/run/vsftpd/empty

# if user id does not exist
if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "Creating FTP user: $FTP_USER..."

    # add a user called $FTP_USER whose HOME is /var/www/html
    # in vsftpd.conf, all FTP connections are directed to mounted WordPress volume (local_root=/var/www/html)
    # -M: do not create "/home/ftp_user" directory (-m is the opposite)
    # -d: set user's HOME path = /var/www/html
    # -s: set bash as shell
    useradd -M -d /var/www/html -s /bin/bash "$FTP_USER"

    # chpasswd: change password tool
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

    # add FTP user to WordPress's www-data group (avoid conflict of authority)
    # usermod: user modify
    # -a: append (without it, all data will be overwriten!)
    # -G: supplementary groups + group_name
    usermod -aG www-data "$FTP_USER"

else
    echo "FTP user already exists."
fi

echo "FTP Server is starting..."

exec vsftpd /etc/vsftpd.conf

