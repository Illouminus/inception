#!/bin/bash

php_version=$(php -v | head -n 1 | awk '{print substr($2, 1, 3)}')

## php-fpm config
# Listen to 9000
sed -i "s/listen = \/run\/php\/php$php_version-fpm.sock/listen = 9000/" /etc/php/$php_version/fpm/pool.d/www.conf
# Make php in foreground
sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/$php_version/fpm/php-fpm.conf

# Wordpress config
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /usr/local/bin/
chmod +x /usr/local/bin/wp-cli.phar
mv /usr/local/bin/wp-cli.phar /usr/local/bin/wp

# Dow files required by wordpress 
wp core download --path='/var/www/html/wordpress' --allow-root
cd /var/www/html/wordpress
chmod -R 774 /var/www/html/wordpress
chown -R www-data:www-data /var/www/html/wordpress

# Create configuration with database config
if [ ! -f wp-config.php ] ; then
	echo "Creating wp-config.php..."
	wp config create \
		--dbhost=$DB_HOST \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$MYSQL_PASSWORD \
		--dbprefix=wp_ \
		--allow-root
fi

# If WP is installed then create admin and users profile

if ! wp core is-installed --allow-root ; then
	echo "Installing Wordpress..."
	wp core install \
		--url=ebaillot.42.fr \
		--admin_email=$WP_ADMIN_EMAIL \
		--title="Inception" \
		--admin_user=$WP_ADMIN_USER \
		--admin_password=$WP_ADMIN_PASSWORD \
		--skip-email \
		--allow-root

    echo "Updating siteurl and home options..."
    wp option update siteurl "https://ebaillot.42.fr" --path=/var/www/html/wordpress --allow-root  
    wp option update home "https://ebaillot.42.fr" --path=/var/www/html/wordpress --allow-root
	echo "Creating user $WP_USER..."
	wp user create \
		$WP_USER $WP_USER_EMAIL \
		--role=editor \
		--user_pass=$WP_USER_PASSWORD \
		--allow-root
fi

# Install and activate theme
THEME_NAME="inspiro"
if ! wp theme is-installed "$THEME_NAME" --allow-root; then
    echo "Installing theme $THEME_NAME..."
    wp theme install "$THEME_NAME" --activate --allow-root
	 wp option update blogname "Inception from Edouard" --allow-root
    echo "Theme $THEME_NAME installed and activated successfully."
    wp cache flush --allow-root --path='/var/www/html/wordpress'
fi

php-fpm$php_version -F -R --nodaemonize
