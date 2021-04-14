# A testing tool for MariaDB.

[![Build](https://github.com/junaruga/mysql-test/actions/workflows/build.yml/badge.svg)](https://github.com/junaruga/mysql-test/actions/workflows/build.yml)

A developing and testing tool for an application using MySQL / MariaDB.
It provies a wrapping script to run a MariaDB server by [the official MariaDB container](https://hub.docker.com/_/mariadb).

## Getting started

Install [Docker](https://www.docker.com/) or [Podman](https://podman.io/).

Run the following command to start a MariaDB server.
Here is actualy an example by *`podman`* command. You might see a little different result when using `docker` command.

```
$ DB_IMAGE_TAG=10.5-focal HOST_PORT=13306 \
  ci/setup_db_container.sh
```

You see the running container.

```
$ docker ps
CONTAINER ID  IMAGE                                  COMMAND       CREATED        STATUS            PORTS                       NAMES
b22134881281  docker.io/library/mariadb:10.5-focal   --port=13306  9 minutes ago  Up 9 minutes ago  127.0.0.1:13306->13306/tcp  mariadb-10.5-focal
```

You can access the database server by a client tool `mysql`.

```
$ mysql -h 127.0.0.1 -u root -P 13306 -e 'SELECT @@version'
+-------------------------------------+
| @@version                           |
+-------------------------------------+
| 10.5.9-MariaDB-1:10.5.9+maria~focal |
+-------------------------------------+
```

Stop and remove the container.

```
$ docker ps
$ docker stop mariadb-10.5-focal
$ docker kill mariadb-10.5-focal
$ docker ps -a
$ docker rm mariadb-10.5-focal
```

## Environment variables

| NAME | Description | Value | Default |
| ---- | ----------- | ----- | ------- |
| DB_IMAGE_TAG | A tag of image on [the official MariaDB container image](https://hub.docker.com/_/mariadb). | 10.5-focal, 10.4-focal, 10.3-focal, 10.2-bionic, 10.1-bionic, 10.0-xenial are tested. | 10.5-focal |
| HOST | A host of the database server | NNN.NNN.NNN.NNN (IP Address) | 127.0.0.1 |
| HOST_PORT | A listening port of the database server on host. | N (<= 65535) | 3306 (MariaDB default listning port) |
| DOCKER | A used container command. If it is not specified, `docker, `podman` are searched in order. | docker or podman | docker or podman |

The each environment variable is optional.

## Special thanks!

I referred the following pages.

* https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/
* [MariaDB GitHub Action](https://github.com/getong/mariadb-action): [License: MIT](https://github.com/getong/mariadb-action/blob/master/LICENSE)
