#!/bin/bash
sudo yum update -y
sudo yum install httpd php php-mysql php-xml php-mbstring -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo usermod -a -G apache ec2-user
sudo su - ec2-user
groups
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
sudo cp phpMyAdmin/config.sample.inc.php phpMyAdmin/config.inc.php
sed -i 's/localhost/${aws_db_instance.RDS.address}/g'  phpMyAdmin/config.inc.php ####Duhet gjetur gabimi , pasi nuk futet endpoint si nje value ne shell script!
sed -i "s/blowfish_secret'] = ''/blowfish_secret'] = '12345678901234567890123456789012'/g"  phpMyAdmin/config.inc.php
sudo chmod 660 phpMyAdmin/config.inc.php
sudo systemctl restart httpd
