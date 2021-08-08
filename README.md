# docker-php-fpm

[![Docker Pulls](https://img.shields.io/docker/pulls/j33r/php-fpm?style=flat-square)](https://hub.docker.com/r/j33r/php-fpm)
[![DockerHub](https://shields.io/badge/Dockerhub-j33r/php%E2%88%92fpm-%232496ED?logo=docker&style=flat-square)](https://hub.docker.com/r/j33r/php-fpm)

A docker image for [php-fpm](https://php.net/) based on [PHP official docker images 7-fpm-Alpine](https://hub.docker.com/_/php/)

# Supported tags

| Tags | Size | Build Status |
|-|-|-|
| `latest`, `stable`, `master` | ![](https://img.shields.io/docker/image-size/j33r/php-fpm/latest?style=flat-square) | [![Drone (cloud) master build](https://img.shields.io/drone/build/jee-r/docker-php-fpm?label=latest&style=flat-square)](https://cloud.drone.io/jee-r/docker-php-fpm) |
| `dev` | ![](https://img.shields.io/docker/image-size/j33r/php-fpm/dev?style=flat-square) | [![Drone (cloud) dev build](https://img.shields.io/drone/build/jee-r/docker-php-fpm?label=dev&style=flat-square)](https://cloud.drone.io/jee-r/docker-php-fpm) |

# What is PHP-FPM?

From [php.net](https://php.net):

>   PHP is a popular general-purpose scripting language that is especially suited to web development.
>   Fast, flexible and pragmatic, PHP powers everything from your blog to the most popular websites in the world.

# How to use these images

All the lines commented in the examples below should be adapted to your environment. 

Note: `--user $(id -u):$(id -g)` should work out of the box on linux systems. If your docker host run on windows or if you want specify an other user id and group id just replace with the appropriates values.

```bash
docker run \
    --detach \
    --interactive \
    --name php-fpm \
    #--user $(id -u):$(id -g) \
    #--env TZ=Europe/Paris
    #--volume /path/to/your/php-fpm.conf:/etc/php7/php-fpm.conf \
    #--volume /path/to/your/php.ini:/etc/php7/conf.d/00_custom.ini \
    #--volume /path/to/your/app:/app \
    #--volume php:/php \
    #--volume /etc/localtime:/etc/localtime:ro \
    j33r/php-fpm:latest
```

See also the [Docker Compose section](#Docker-Compose-LEMP).

## Volume mounts

- `/app`: the directory containing the application
- `/etc/php7/php-fpm.conf`: if you want overwrite default the [php-fpm.conf](https://www.php.net/manual/en/install.fpm.configuration.php)
- `/etc/php7/conf.d/00_custom.ini`: if you want overwrite default [php.ini config](https://www.php.net/manual/en/configuration.file.php)
- `/app/phpinfo.php` instead of running an application you can mount this file to get [php info](https://www.php.net/manual/en/function.phpinfo.php)
- `/php` the directory where php store the php-fpm.[pid](https://www.php.net/manual/en/install.fpm.configuration.php) and php-fpm.[socket](https://www.php.net/manual/en/install.fpm.configuration.php) files it's virtual volume so you can share it between container.

You should create directory before run the container otherwise directories are created by the docker deamon and owned by the root user

## Environment variables

To change the timezone of the container set the `TZ` environment variable. The full list of available options can be found on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

You can also set the `HOME` environment variable this is usefull to get in the right directory when you attach a shell in your docker container.

## PHP Modules

### Available Php modules :

`Core`, `ctype`, `curl`, `date`, `dom`, `fileinfo`, `filter`, `ftp`, `gmp`, `hash`, `iconv`, `intl`, `json`, `libxml`, `mbstring`, `mysqli`, `mysqlnd`, `openssl`, `pcre`, `PDO`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `Phar`, `posix`, `readline`, `Reflection`, `session`, `SimpleXML`, `sodium`, `SPL`, `sqlite3`, `standard`, `tokenizer`, `xml`, `xmlreader`, `xmlwriter`, `OPcache`, `zip`, `zlib`

### How install additionnal module :

if your php project need additionnals modules, easiest method is to use the tool [docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer) which is installed by default in this image. 

```
docker exec -it my_php_app /usr/local/bin/docker-php-extension-installer gd 
```

or by writing you own `Dockerfile`: 

```
FROM j33r/php-fpm:latest

RUN /usr/local/bin/docker-php-extension-installer gd
```

## Socket vs port

By default   [PHP official docker images](https://hub.docker.com/_/php/) use `tcp` protocol to bind `php-fpm` to a web-server ([apache](https://apache.org), [nginx](https://apache.org/)...). Socket file path is accessible on `/php/php-fpm.socket`
If you want use `socket` protocol instead you need to overwrite `listen` value in [php-fpm.conf](https://www.php.net/manual/en/install.fpm.configuration.php) to `listen = /php/php-fpm.sock`

## Logs

If you use this image for developement purpose you will need  to see some to debug your stuff. By default php's error and access logs [are redirected](rootfs/etc/php7/php-fpm.conf#L3) to container logs.

```bash
docker logs --follow php-fpm
# or with docker-compose
docker-compose log --follow php-fpm
# Ctrl+C to quit
```  

## Docker Compose LEMP

[`docker-compose`](https://docs.docker.com/compose/) can help with defining the `docker run` config in a repeatable way rather than ensuring you always pass the same CLI arguments.

**(Linux + Engine x + Mysql + Php)**

- nginx (no root)
  - [nginxinc/nginx-unprivileged:alpine](https://hub.docker.com/r/nginxinc/nginx-unprivileged)
  - https://github.com/nginxinc/docker-nginx-unprivileged
- db :
  - [mariadb:latest](https://hub.docker.com/_/mariadb)
  - [postgres:alpine](https://hub.docker.com/_/postgres)

Here's an example `docker-compose.yml` config. Don't forget to **modify db passwords** specialy if you use this stack in produstion :

```yaml
version: "3"

services:
  php:
    image: j33r/php-fpm:latest    
    user: "${UID:-1000}:${GID:-1000}"
    restart: unless-stopped
    environment:
      - HOME=/app
      - TZ=Europe/Paris
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./php-fpm.conf:/etc/php7/php-fpm.conf
      - ./php_custom.ini:/etc/php7/conf.d/00_custom.ini
      - ./myapp:/app
      - php:/php

  nginx:
    image: nginxinc/nginx-unprivileged:alpine
    user: "${UID:-1000}:${GID:-1000}"
    restart: unless-stopped
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./nginx_default.conf:/etc/nginx/conf.d/default.conf
      - ./myapp:/app
      - php:/php
    ports:
      - "0.0.0.0:8080:8080"

  db:
    image: mariadb:latest
    container_name: db
    restart: unless-stopped
    volumes:
      - db:/var/lib/mysql/data
    environment:
      - MYSQL_RANDOM_ROOT_PASSWORD=yes
      - MYSQL_DATABASE=database
      - MYSQL_USER=db_user
      - MYSQL_PASSWORD=db_password

  # db:
  #  image: postgres:alpine
  #  container_name: postgres
  #  restart: unless-stopped
  #  networks:
  #    - php-app
  #  volumes:
  #    - db:/var/lib/postgresql/data
  #  environment:
  #    - POSTGRES_USER=db_user
  #    - POSTGRES_PASSWORD=db_password
  #    - POSTGRES_DB=database

volumes:
  php:
  db:
```

# Contributions

### Short Story
```bash
# fork this repo then :
git clone https://github/<YourName>/docker-php-fpm.git
cd docker-php-fpm
git checkout dev
git pull origin dev
# Do what you need to do, when you'r done then
git add <modified.file> <second.modified.file> <whatever>
git commit -m 'Your message that describe your change'
git push origin dev
# Submit a pull-request
```
### Long Story
* [Fork this repo](https://duckduckgo.com/?q=how+fork+a+git+repository)

* Clone your fork of this repo \
  `git clone https://github/<YourName>/docker-php-fpm.git`

* **Always work on the `dev`  branch** \
    `cd docker-php-fpm` \
    `git checkout dev`

* be sure your fork's dev branch is up to database \
  `cd docker-php-fpm` \
  `git pull origin dev`

* Do what you need to do and when you'r done then \
  For typo please try to make less commits as possible.

* Add and commit your modifications \
  `git add <modified.file> <second.modified.file> <whatever>` \
  `git commit -m 'Your message that describe your change'`

* push on your fork \
  ` git push origin dev` \

* And finaly [open a pull request](https://github.com/jee-r/docker-php-fpm/compare) comparing your dev branch with mine

If you find a vulnerability please contact me by mail

# License

This project is under the [GNU Generic Public License v3](https://github.com/jee-r/docker-php-fpm/blob/master/LICENSE) to allow free use while ensuring it stays open.
