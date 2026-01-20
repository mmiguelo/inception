# cAdvisor - Container monitoring tool
# https://github.com/google/cadvisor

FROM    debian:bookworm

# Install dependencies and clean up
RUN apt update -y && apt-get install -y \
	curl \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set cAdvisor version and architecture
ENV CADVISOR_VERSION=v0.49.2
ENV ARCH=amd64

# Download cAdvisor binary
RUN curl -Lo /usr/bin/cadvisor "https://github.com/google/cadvisor/releases/download/${CADVISOR_VERSION}/cadvisor-${CADVISOR_VERSION}-linux-${ARCH}" && \
    chmod +x /usr/bin/cadvisor

# Expose cAdvisor port
EXPOSE 8080

# Run cAdvisor
CMD ["/usr/bin/cadvisor"]