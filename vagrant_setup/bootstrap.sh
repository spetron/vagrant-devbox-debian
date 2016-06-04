#!/usr/bin/env bash

#export DEBIAN_FRONTEND=noninteractive

# Include parameteres file
# ------------------------
HOSTNAME=$1
HOSTIP=$2
DATETIMEZONE=$3
MYSQL_ROOTUSER=$4
MYSQL_ROOTPASS=$5

sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

#source /vagrant/vagrant_setup/parameters.sh

echo '******************************************'
echo -e "\n--- Copying aliases default file ---\n"
echo '------------------------------------------'
sudo cp /vagrant/vagrant_setup/files/bash_aliases /root/.bash_aliases

sudo sed -i "/.bash_aliases/d"  /root/.bashrc

echo ' ' >> /root/.bashrc
echo '. ~/.bash_aliases' >> /root/.bashrc

# Set timezone
echo '******************************************'
echo -e "\n--- Set/configure timezone ---\n"
echo '------------------------------------------'
echo "$DATETIMEZONE" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

echo '******************************************'
echo -e "\n--- Adding dotdeb debian urls ---\n"
echo '------------------------------------------'

sudo rm -rf /etc/apt/sources.list.d/dotdeb.list
echo "deb http://packages.dotdeb.org jessie all" | sudo tee -a /etc/apt/sources.list.d/dotdeb.list
echo "deb-src http://packages.dotdeb.org jessie all" | sudo tee -a /etc/apt/sources.list.d/dotdeb.list
wget -qO - https://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -


echo '******************************************'
echo -e "\n--- update / upgrade ---\n"
echo '------------------------------------------'
sudo apt-get -y update
sudo apt-get -y upgrade

echo '******************************************'
echo -e "\n--- Install utilities ---\n"
echo '------------------------------------------'
sudo apt-get install -y zip unzip curl htop nano alpine lynx links

# install apache 2.5 and php
rm -rf /etc/apache2/sites-available/000-default.conf

echo '******************************************'
echo -e "\n--- Install Apache ---\n"
echo '------------------------------------------'
sudo apt-get install -y apache2
###echo "ServerName localhost" > /etc/apache2/httpd.conf

echo '******************************************'
echo -e "\n--- Enable Apache mod_rewrite ---\n"
echo '------------------------------------------'
a2enmod rewrite

echo '******************************************'
echo -e "\n--- Apache conf copy ---\n"
echo '------------------------------------------'
sudo cat /vagrant/vagrant_setup/files/default.conf | tee /etc/apache2/sites-available/000-default.conf
sudo sed -i "s%HOSTNAME%$HOSTNAME%g" /etc/apache2/sites-available/000-default.conf

sudo sed -i "/$HOSTIP $HOSTNAME/d"  /etc/hosts
echo " " >> /etc/hosts
echo " " >> /etc/hosts
echo $HOSTIP $HOSTNAME >> /etc/hosts


echo '******************************************'
echo -e "\n--- Restart apache ---\n"
echo '------------------------------------------'
service apache2 restart

echo '******************************************'
echo -e "\n--- Install MySQL ---\n"
echo '------------------------------------------'
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOTPASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOTPASS"
sudo apt-get -y install mysql-server mysql-client > /dev/null 2>&1


#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
#sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
#sudo apt-get -y install phpmyadmin


echo '******************************************'
echo -e "\n--- Install POSTGRESQL ---\n"
echo '------------------------------------------'
sudo apt-get -y install postgresql


echo '******************************************'
echo 'Install PHP 7.x'
echo '------------------------------------------'
##sudo apt-get install -y php7-*
sudo apt-get install -y php7.0
sudo apt-get install -y php7.0-fpm php7.0-imagick php7.0-curl php7.0-gd php7.0-xmlrpc php7.0-common php7.0-intl php7.0-json php7.0-ldap php7.0-mcrypt php7.0-pgsql php7.0-opcache php7.0-mysql php7.0-xdebug
sudo apt-get install -y libapache2-mod-php7.0


echo '******************************************'
echo 'Configure PHP'
echo '------------------------------------------'
#sudo sed -i '/;sendmail_path =/c sendmail_path = "/usr/local/bin/catchmail"' /etc/php/7.0/apache2/php.ini
sudo sed -i '/display_errors = Off/c display_errors = On' /etc/php/7.0/apache2/php.ini
sudo sed -i '/error_reporting = E_ALL & ~E_DEPRECATED/c error_reporting = E_ALL | E_STRICT' /etc/php/7.0/apache2/php.ini
sudo sed -i '/html_errors = Off/c html_errors = On' /etc/php/7.0/apache2/php.ini


echo '******************************************'
echo 'xdebug Config'
echo '------------------------------------------'
sudo rm -rf etc/php/7.0/mods-available/xdebug.ini
sudo cp /vagrant/vagrant_setup/files/xdebug.ini /etc/php/7.0/mods-available/
cd /etc/php/7.0/apache2/conf.d;
sudo ln -s --force /etc/php/7.0/mods-available/xdebug.ini 30-xdebug.ini



echo '******************************************'
echo ' Downloading phpMyAdmin '
echo '------------------------------------------'
sudo mkdir -p "/var/www/3rdParty/"
sudo wget -q https://files.phpmyadmin.net/phpMyAdmin/4.6.2/phpMyAdmin-4.6.2-english.tar.gz -O pma.tar.gz
sudo mkdir -p /var/www/3rdParty/pma && tar xf pma.tar.gz -C /var/www/3rdParty/pma --strip-components 1
sudo cp /var/www/3rdParty/pma/config.sample.inc.php /var/www/3rdParty/pma/config.inc.php
sudo rm -rf pma.tar.gz

echo '******************************************'
echo ' install Composer '
echo '------------------------------------------'
sudo curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer



# Install Mailcatcher
#echo "Installing mailcatcher"
#gem install mailcatcher --no-ri --no-rdoc
#mailcatcher --http-ip=192.168.10.11

# restart apache
service apache2 restart


sudo apt-get --purge autoremove -y
