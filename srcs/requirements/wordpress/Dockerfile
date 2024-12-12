FROM debian:bullseye


# Install necessary packages: wget for downloading, php-fpm for PHP backend, php-mysql for database interaction
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	wget \
	php-mysql \
	php-fpm \
	&& rm -rf /var/lib/apt/lists/*


# Create the directory required by PHP-FPM to store its runtime socket
RUN mkdir -p /run/php/

# Copy the script to setup the WordPress website and make it executable
COPY ./tools/wordpress-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-setup.sh


# Create the directory where the WordPress website will be stored and set the owner to www-data
RUN mkdir -p /var/www/html
RUN chown -R www-data:www-data /var/www/html

ENTRYPOINT [ "wordpress-setup.sh" ]