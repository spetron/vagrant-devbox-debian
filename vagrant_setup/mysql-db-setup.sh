#!/usr/bin/env bash

DBNAME=$1;
DBUSER=$2;
DBPASS=$3;
ROOTUSER=$4;
ROOTPASS=$5;

# Configure MySQL database and user
# ---------------------------------
    echo "DROP DATABASE IF EXISTS test" | mysql -u$ROOTUSER -p$ROOTPASS
    echo "DROP DATABASE IF EXISTS ${DBNAME}" | mysql -u$ROOTUSER -p$ROOTPASS
    echo "GRANT USAGE ON *.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}'" | mysql -u$ROOTUSER -p$ROOTPASS
    echo "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${DBUSER}'@'localhost';" | mysql -u$ROOTUSER -p$ROOTPASS
    echo "DROP USER '${DBUSER}'@'localhost'" | mysql -u$ROOTUSER -p$ROOTPASS

if [ "$DBNAME" != "" ];
then

    echo "CREATE DATABASE IF NOT EXISTS ${DBNAME} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci" | mysql -u$ROOTUSER -p$ROOTPASS
    echo "CREATE USER '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}'" | mysql -u$ROOTUSER -p$ROOTPASS
    echo "GRANT ALL ON ${DBNAME}.* TO '${DBUSER}'@'localhost'" | mysql -u$ROOTUSER -p$ROOTPASS
    echo "FLUSH PRIVILEGES" | mysql -u$ROOTUSER -p$ROOTPASS

fi


# Edit my.cnf to unbind localhost
#if [ "$DATABASE_ROOT_HOST" != "localhost" ];
#then
#  sed "s/bind-address\([[:space:]]*\)=\([[:space:]]*\)127.0.0.1/bind-address\1=\20.0.0.0/g" /etc/mysql/my.cnf > /etc/mysql/my.cnf.tmp
#  mv /etc/mysql/my.cnf.tmp /etc/mysql/my.cnf
#  # Edit the root user
#  echo "use mysql; UPDATE user SET Host = '%' WHERE User = 'root' AND Host = '::1'" | mysql
#  # Restart MySQL to reload edited configuration file
#  service mysql restart
#fi

