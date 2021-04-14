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
# $ docker ps -a
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
DOCKER="${DOCKER:-}"
if [ DOCKER != "" ]; then
  DOCKER="$(command -v docker || command -v podman)"
fi
DB="${DB:-mariadb}"
DB_IMAGE_TAG="${DB_IMAGE_TAG:-10.5-focal}"
IMAGE="${DB}:${DB_IMAGE_TAG}"
# The ":" is not allowed as a character of the name.
CONTAINER_NAME="${DB}-${DB_IMAGE_TAG}"
# We need to set the lo IP. The "localhost" does not work.
HOST="127.0.0.1"
HOST_PORT="${HOST_PORT:-3306}"
CONTAINER_PORT="${HOST_PORT}"

if "${DOCKER}" ps -f name="${CONTAINER_NAME}" | grep -q ${CONTAINER_NAME}; then
  echo "Stopping running container..."
  "${DOCKER}" stop "${CONTAINER_NAME}"
fi
if "${DOCKER}" ps -a -f name="${CONTAINER_NAME}" | grep -q ${CONTAINER_NAME}; then
  "${DOCKER}" rm "${CONTAINER_NAME}"
fi

# Set a volume -v option to put custom my.cnf and *.pem files to enable SSL.
# TODO: Set multiple cnf files on /etc/mysql/conf.d. A cnf file for an feature.
#   https://mariadb.com/kb/en/multiple-db-instances-in-multiple-cnf-files/
"${DOCKER}" run \
  --rm \
  --name "${CONTAINER_NAME}" \
  -d \
  -p "${HOST}:${HOST_PORT}:${CONTAINER_PORT}" \
  -e MYSQL_DATABASE=test \
  -v $(pwd)/etc/mysql/conf.d:/etc/mysql/conf.d \
  -v $(pwd)/etc/mysql/ssl:/etc/mysql/ssl \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=true \
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
# TODO: Find a better line separator instead of SELECT '==..='.
mysql -h "${HOST}" -u root -P "${HOST_PORT}" -B -e "
status;
SELECT '==============';
SHOW VARIABLES;
SELECT '==============';
SHOW VARIABLES LIKE '%ssl%';
SELECT '==============';
SHOW VARIABLES WHERE Variable_name IN ('have_ssl', 'local_infile', 'performance_schema', 'performance_schema_users_size');
SELECT '==============';
SHOW ENGINES;
"
