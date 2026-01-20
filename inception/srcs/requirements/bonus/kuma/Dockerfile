# Uptime Kuma - Self-hosted monitoring tool
# https://github.com/louislam/uptime-kuma

FROM    debian:bookworm

EXPOSE  3001

# Install Node.js and dependencies
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        curl \
        ca-certificates \
        gnupg && \
        mkdir -p /etc/apt/keyrings && \
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
        apt update && \
        apt install -y nodejs && \
        rm -rf /var/lib/apt/lists/*

# Install git for cloning Uptime Kuma
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        git && \
        rm -rf /var/lib/apt/lists/*

# Clone and setup Uptime Kuma
WORKDIR /app

RUN     git clone https://github.com/louislam/uptime-kuma.git . && \
        npm ci --production && \
        npm run download-dist

# Create data directory
RUN     mkdir -p /app/data

# Run Uptime Kuma
CMD     ["node", "server/server.js"]