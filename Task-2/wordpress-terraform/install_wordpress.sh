#!/bin/bash

# Update package list
sudo apt update

# Install Apache
sudo apt install apache2 -y

# Install MySQL
sudo apt install mysql-server -y

# Secure MySQL
sudo mysql_secure_installation

# Install PHP
sudo apt install php libapache2-mod-php php-mysql -y

# Download WordPress
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

# Set permissions
sudo chown -R www-data:www-data wordpress
sudo mv wordpress /var/www/html/

# Configure Apache
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/wordpress|' /etc/apache2/sites-available/wordpress.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Create MySQL database
sudo mysql -u root -p -e "CREATE DATABASE wordpress; CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost'; FLUSH PRIVILEGES;"

echo "WordPress installed successfully."
