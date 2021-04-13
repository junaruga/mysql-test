#!/usr/bin/env bash

set -eux

# A script to set up MariaDB container.
# https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/
#
# Usage:
# An example with the container's tag: 10.5-focal.
# https://hub.docker.com/_/mariadb
#
# To run a database server by starting the container.
# $ HOST_PORT=13306 DB_IMAGE_TAG=10.5-focal \
#     ci/setup_db_container.sh
#
# To remove the container.
# $ docker ps
# $ docker stop mariadb-10.5-focal
# $ docker kill mariadb-10.5-focal
# $ docker container ls -a
# $ docker rm mariadb-10.5-focal
#
# To see the database server logs in the container.
# $ docker logs mariadb-10.5-focal
#
# To login to the container.
# $ docker exec -it mariadb-10.5-focal bash
#
# To connect from the client command.
# mysql -h 127.0.0.1 -u root -P 13306 -e status

# Container command: docker/podman.
DOCKER="${DOCKER:-docker}"
DB="${DB:-mariadb}"
DB_IMAGE_TAG="${DB_IMAGE_TAG:-}"
IMAGE="${DB}:${DB_IMAGE_TAG}"
# The ":" is not allowed as a character of the name.
CONTAINER_NAME="${DB}-${DB_IMAGE_TAG}"
# We need to set the lo IP. The "localhost" does not work.
HOST="127.0.0.1"
HOST_PORT="${HOST_PORT:-3306}"
CONTAINER_PORT="${HOST_PORT}"

"${DOCKER}" run --rm -p "${HOST}:${HOST_PORT}:${CONTAINER_PORT}" \
  --name "${CONTAINER_NAME}" \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d \
  -e MYSQL_DATABASE=test \
  "${IMAGE}" --port="${CONTAINER_PORT}"

# Check the container.
"${DOCKER}" ps
# Check the listening ports status.
ss -lntp

"${DOCKER}" exec -t "${CONTAINER_NAME}" /usr/sbin/mysqld --version

# Wait enough until the service is running.
SLEEP_TIME=5
for i in $(seq 10); do
  sleep "${SLEEP_TIME}"
  if mysql -h "${HOST}" -u root -P "${HOST_PORT}" -e "SELECT 1" > /dev/null; then
    break
  fi
  echo "Waiting connections... $((${i}*${SLEEP_TIME})) sec"
done

"${DOCKER}" logs "${CONTAINER_NAME}"
# Show server status and info.
# https://mariadb.com/kb/en/show-variables/
mysql -h "${HOST}" -u root -P "${HOST_PORT}" -B -e "
status;
SELECT '==============';
SHOW VARIABLES;
SELECT '==============';
SHOW VARIABLES WHERE Variable_name IN ('have_ssl', 'local_infile', 'performance_schema', 'performance_schema_users_size');
SELECT '==============';
SHOW ENGINES;
"
