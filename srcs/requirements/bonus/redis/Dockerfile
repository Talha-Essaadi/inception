FROM debian:12

RUN apt-get update && \
    apt-get install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

COPY tools/redis.conf /etc/redis/redis.conf

RUN mkdir -p /var/lib/redis && \
    chown -R redis:redis /var/lib/redis /etc/redis

USER redis

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]