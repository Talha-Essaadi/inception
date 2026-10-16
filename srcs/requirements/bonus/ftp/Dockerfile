FROM debian:12

RUN apt-get update && \
    apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/init.sh /usr/local/bin/init.sh

RUN mkdir -p /var/run/vsftpd/empty
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 21
EXPOSE 21000-21010

ENTRYPOINT ["/usr/local/bin/init.sh"]