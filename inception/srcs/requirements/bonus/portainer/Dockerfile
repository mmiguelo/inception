# Portainer - Container management UI
# https://docs.portainer.io/

FROM    debian:bookworm

EXPOSE  9443

# Install dependencies
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        wget \
        ca-certificates \
        tar && \
        rm -rf /var/lib/apt/lists/*

# Download and extract Portainer (latest version)
RUN     wget -q https://github.com/portainer/portainer/releases/download/2.33.6/portainer-2.33.6-linux-amd64.tar.gz \
        -O /tmp/portainer.tar.gz && \
        tar -xzf /tmp/portainer.tar.gz -C /opt/ && \
        rm /tmp/portainer.tar.gz

# Create data directory
RUN     mkdir -p /data

WORKDIR /opt/portainer

# Run Portainer (HTTPS on port 9443)
CMD     ["/opt/portainer/portainer", "--bind-https", ":9443"]
