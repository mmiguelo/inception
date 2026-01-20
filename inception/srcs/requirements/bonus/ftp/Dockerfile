# FTP Server - vsftpd for WordPress file management
# https://security.appspot.com/vsftpd.html

FROM    debian:bookworm

EXPOSE  20 21

# Install vsftpd
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        vsftpd && \
        rm -rf /var/lib/apt/lists/*

# Create directory for vsftpd empty chroot jail
RUN     mkdir -p /var/run/vsftpd/empty

# Copy vsftpd config file
COPY    conf/vsftpd.conf /etc/vsftpd.conf

# Copy setup script
COPY    tools/setup.sh /bin/
RUN     chmod +x /bin/setup.sh

CMD     ["setup.sh"]
