#!/usr/bin/env bash

set -eux

DB="${DB-}"

sudo service mysql stop
sudo apt-get purge -qq '^mysql*' '^libmysql*'
sudo rm -fr /etc/mysql
sudo rm -fr /var/lib/mysql

sudo apt-get update
sudo apt-get install -qq "${DB}"

sudo service mariadb status
