# Redis - In-memory data structure store (for WordPress caching)
# https://redis.io/

FROM    debian:bookworm

EXPOSE  6379

# Install Redis
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        redis-server && \
        rm -rf /var/lib/apt/lists/*

# Copy custom Redis configuration
COPY    conf/redis.conf /etc/redis/redis.conf

# Run Redis server with the config file
CMD     ["redis-server", "/etc/redis/redis.conf"]
