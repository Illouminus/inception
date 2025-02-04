FROM debian:bullseye

# Install MariaDB
RUN apt-get update && apt-get install -y \
	mariadb-server \
	libaio1 \
	&& rm -rf /var/lib/apt/lists/*

# Copy MariaDB configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy MariaDB initialization script
COPY tools/init-db.sh /init-db.sh
RUN chmod +x /init-db.sh

# Create directories for MariaDB and set permissions
RUN mkdir -p /var/lib/mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
	chmod 750 /var/lib/mysql /var/run/mysqld

# Init MariaDB database for first run
RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql --basedir=/usr

# Expose MariaDB port
EXPOSE 3306

ENTRYPOINT ["/init-db.sh"]
