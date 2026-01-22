# the base of container has to be the most stable version of Debian: bookworm
FROM    debian:bookworm

# expose port 3306 to external communication with container
EXPOSE  3306

# EXPOSE 3310 if you want to change the default port

# update reps of debian and install mariadb
RUN     apt update && \
        apt install -y --no-install-recommends --no-install-suggests \
        mariadb-server && \
        rm -rf /var/lib/apt/lists/*

# copy config files of mariadb to container
COPY    conf/50-server.cnf /etc/mysql/mariadb.conf.d/

# copy config script of mariadb to /bin dir of container
COPY    tools/setup.sh /bin/

# make sure "setup.sh" script has execute permissions
RUN     chmod +x /bin/setup.sh

# initialize mariadb server in a safe way with "setup.sh" script
CMD     ["setup.sh", "mysqld_safe"]
