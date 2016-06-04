#!/usr/bin/env bash

DBNAME=$1;
DBUSER=$2;
DBPASS=$3;
DBFILE=$4;
ROOTUSER=$5;
ROOTPASS=$6;

#DBFILE = /vagrant/$DBFILE;

echo '******************************************'
echo 'IMPORT POSTGRESQL DEFAULT DB SQL'
echo '------------------------------------------'
if [ -f $DBFILE ];
then
    set PGPASSWORD=$ROOTPASS

    psql -d $DBNAME -U $ROOTUSER -f $DBFILE

    echo '+++ DONE +++'

fi

echo '******************************************'
echo 'FINISHED'
echo '------------------------------------------'
