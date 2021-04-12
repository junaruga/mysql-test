#!/usr/bin/env bash

set -eux

# Set up MariaDB container.
# https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/
# https://github.com/getong/mariadb-action/blob/master/entrypoint.sh
#
# How to use.
# $ DOCKER=podman \
#   HOST_PORT=13306 \
#   DB_IMAGE_TAG=10.5-focal \
#     ci/setup_db_container.sh
#
# To remove the container.
# ex.
# $ podman ps
# $ podman stop mariadb-10.5-focal
# $ podman kill mariadb-10.5-focal
# $ podman container ls -a
# $ podman rm mariadb-10.5-focal
#
# To see the log in the container.
# $ podman logs mariadb-10.5-focal
#
# To login to the container.
# $ podman exec -it mariadb-10.5-focal bash

# container command: docker/podman.
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
# Check listning port status
ss -lntp

"${DOCKER}" exec -t "${CONTAINER_NAME}" /usr/sbin/mysqld --version

# Wait enough until the service is running.
SLEEP_TIME=5
for i in $(seq 10); do
  sleep "${SLEEP_TIME}"
  if mysql -h "${HOST}" -u root -P "${HOST_PORT}" -e status > /dev/null; then
    break
  fi
  echo "Waiting connections... $((${i}*${SLEEP_TIME})) sec"
done

"${DOCKER}" logs "${CONTAINER_NAME}"
mysql -h "${HOST}" -u root -P "${HOST_PORT}" -e status
