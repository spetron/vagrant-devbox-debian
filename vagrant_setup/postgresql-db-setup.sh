#!/usr/bin/env bash

DBNAME=$1;
DBUSER=$2;
DBPASS=$3;
ROOTUSER=$4;
ROOTPASS=$5;

# su postgres -c "dropdb $DB --if-exists"
set PGPASSWORD=$ROOTPASS
su postgres -c "createdb -O $ROOTUSER '$DBNAME' || true"
