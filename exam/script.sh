#!/bin/bash

# Install Apache
sudo apt-get update
sudo apt-get install -y apache2

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
sudo apt-get install -y mysql-server

# Install PHP and PHP addons
sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql
sudo apt-get install -y php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc
sudo systemctl restart apache2

# Create database and user for WordPress
mysql -uroot -ppassword -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -uroot -ppassword -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'passworduser';"
mysql -uroot -ppassword -e "FLUSH PRIVILEGES;"

# Add ServerNeame to apache
sudo sed -i '$s&$&\n\nServerName localhost&' /etc/apache2/apache2.conf
#Enable .htaccess Overrides
sudo sed -i '$s&$&\n\n<Directory /var/www/html/>\n    AllowOverride All\n</Directory>&' /etc/apache2/apache2.conf

# Enable module Rewrite
sudo a2enmod rewrite

# Apply changes
sudo systemctl restart apache2

# Download and unzip WordPress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

# Create .htaccess
touch /tmp/wordpress/.htaccess
chmod 660 /tmp/wordpress/.htaccess

cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php

mkdir /tmp/wordpress/wp-content/upgrade

sudo cp -a /tmp/wordpress/. /var/www/html


sudo useradd wordpress
sudo chown -R wordpress:www-data /var/www/html

sudo find /var/www/html -type d -exec chmod g+s {} \;
sudo chmod g+w /var/www/html/wp-content

sudo chmod -R g+w /var/www/html/wp-content/themes
sudo chmod -R g+w /var/www/html/wp-content/plugins

