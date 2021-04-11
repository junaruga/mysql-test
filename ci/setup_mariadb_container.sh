#!/usr/bin/env bash

set -eux

HOST_PORT=3306
CONTAINER_PORT=3306
# We need to set the lo IP. The "localhost" does not work.
HOST="127.0.0.1"

# container command: docker/podman.
DOCKER="${DOCKER:-docker}"

# Set up MariaDB
# https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/
# https://github.com/getong/mariadb-action/blob/master/entrypoint.sh
"${DOCKER}" run --rm -p "${HOST}:${HOST_PORT}:${CONTAINER_PORT}" \
  --name "${CONTAINER_NAME}" \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d \
  -e MYSQL_DATABASE=test \
  "${IMAGE}" --port="${CONTAINER_PORT}"
# Wait enough until the servie is running.
sleep 10
ss -lntp
"${DOCKER}" ps
"${DOCKER}" logs "${CONTAINER_NAME}"
mysql -h "${HOST}" -u root -P "${HOST_PORT}" -e 'SHOW DATABASES'
