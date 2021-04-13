#!/usr/bin/env bash

set -eux

DB_CLIENT="${DB_CLIENT:-}"

# If mysql_config is found, remove it.
# On Ubuntu:focal the libmysqlclient-dev for MySQL is the package.
if command -v mysql_config > /dev/null; then
  PKG=$(dpkg-query -S "$(command -v mysql_config)" | cut -d ':' -f 1)
  echo "A installed database client package: ${PKG} found. Removing it ..."
  sudo apt-get remove -qq "${PKG}"
  sudo apt-get purge -qq "${PKG}"
  sudo apt-get autoremove -qq "${PKG}"
  sudo apt-get clean -qq
fi

if [ -n "${DB_CLIENT}" ]; then
  sudo apt-get install -qq "${DB_CLIENT}"
fi
