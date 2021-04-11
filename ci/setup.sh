#!/usr/bin/env bash

set -eux

DB="${DB-}"

sudo apt-get update
sudo apt-get install -qq "${DB}"

systemctl status mariadb
