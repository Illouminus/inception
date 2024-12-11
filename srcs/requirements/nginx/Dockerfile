FROM debian:bullseye

# Install nginx

RUN apt-get update && apt-get install -y nginx openssl && \
	mkdir -p /etc/nginx/ssl && \
	mkdir -p /var/run/nginx && \
	chmod 755 /var/www/html && \
	chown -R www-data:www-data /var/www/html && \
	openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
	-keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=ebaillot.42.fr/UID=ebaillot"

# Copy the configuration file

COPY conf/inception.conf /etc/nginx/conf.d/

# Expose the port

EXPOSE 443 

# Start the service

CMD ["nginx", "-g", "daemon off;"]