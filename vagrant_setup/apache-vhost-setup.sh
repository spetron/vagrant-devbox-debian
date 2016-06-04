#!/usr/bin/env bash

HOSTIP="$1"
PROJECT_HOST="$2"
PROJECT_FOLDER="$3"

VHOSTFILE=/etc/apache2/sites-available/$PROJECT_HOST.conf

# Apache VHOST
# ------------

cd /etc/apache2/sites-available/;
a2dissite $PROJECT_HOST.conf
rm -rf $PROJECT_HOST.conf

cp /vagrant/vagrant_setup/files/apache.vhost.conf $VHOSTFILE

sudo sed -i "s%PROJECT_HOST%$PROJECT_HOST%g" $VHOSTFILE
sudo sed -i "s%PROJECT_FOLDER%$PROJECT_FOLDER%g" $VHOSTFILE

sudo sed -i "/$HOSTIP $PROJECT_HOST/d"  /etc/hosts
echo $HOSTIP $PROJECT_HOST >> /etc/hosts

a2ensite $PROJECT_HOST.conf