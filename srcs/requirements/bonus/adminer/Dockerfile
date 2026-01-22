# Adminer - Database management tool
# https://www.adminer.org/

FROM    debian:bookworm

EXPOSE  80

# Install PHP and required extensions for Adminer
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        php8.2 \
        php8.2-mysql \
        wget \
        ca-certificates && \
        rm -rf /var/lib/apt/lists/*

# Create web directory
RUN     mkdir -p /var/www/html

# Copy setup script
COPY    tools/setup.sh /bin/
RUN     chmod +x /bin/setup.sh

# Run setup script (downloads latest Adminer and starts PHP server)
CMD     ["setup.sh"]