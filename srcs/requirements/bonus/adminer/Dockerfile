FROM debian:12

RUN apt-get update && \
    apt-get install -y \
        php-fpm \
        php-mysql \
        php-mbstring \
        php-xml \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer

RUN curl -fsSL https://www.adminer.org/latest.php \
    -o /var/www/adminer/index.php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init.sh"]