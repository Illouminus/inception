FROM debian:bullseye

# Устанавливаем MariaDB
RUN apt-get update && apt-get install -y \
	mariadb-server \
	libaio1 \
	&& rm -rf /var/lib/apt/lists/*

# Копируем кастомный конфигурационный файл
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Копируем скрипт инициализации базы данных
COPY tools/init-db.sh /init-db.sh

# Создаём директории для MariaDB и задаём правильные права
RUN mkdir -p /var/lib/mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
	chmod 750 /var/lib/mysql /var/run/mysqld

# Инициализация MariaDB при первом запуске
RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql --basedir=/usr

# Открываем порт MariaDB
EXPOSE 3306

# Используем ENTRYPOINT для запуска скрипта
ENTRYPOINT ["bash", "/init-db.sh"]