#!/usr/bin/env bash

set -eux

DB="${DB-}"

sudo service mysql stop
# sudo apt-get purge -qq '^mysql*' '^libmysql*'
# sudo rm -fr /etc/mysql
# sudo rm -fr /var/lib/mysql

# https://mariadb.com/kb/en/the-community-mariadb-troubles-only-running-after-reboot-times-out-when-try/
sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
sudo aa-status

sudo apt-get update
sudo apt-get install -qq "${DB}"

sudo service mariadb status
