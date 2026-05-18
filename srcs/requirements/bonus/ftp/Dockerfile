FROM debian:bullseye

# vsftpd: very secure FTP daemon
RUN apt-get update && \
    apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# port 21: Control Connection (login password, FTP command ...)
# port 21100-21110: Data Connection(PASiVe Mode) (docker, cloud server, fire wall ...)
EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/setup.sh"]
