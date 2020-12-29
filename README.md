# docker-php-fpm

[![Drone (cloud)](https://img.shields.io/drone/build/jee-r/docker-php-fpm?&style=flat-square)](https://cloud.drone.io/jee-r/docker-php-fpm)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/j33r/php-fpm?style=flat-square)](https://microbadger.com/images/j33r/php-fpm)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/j33r/php-fpm?style=flat-square)](https://microbadger.com/images/j33r/php-fpm)
[![Docker Pulls](https://img.shields.io/docker/pulls/j33r/php-fpm?style=flat-square)](https://hub.docker.com/r/j33r/php-fpm)
[![DockerHub](https://shields.io/badge/Dockerhub-j33r/php%E2%88%92fpm-%232496ED?logo=docker&style=flat-square)](https://hub.docker.com/r/j33r/php-fpm)

A docker image for [php-fpm](https://php.net/) ![php-fpm's logo](https://www.php.net/favicon.ico)

# Supported tags

| Tags | Alpine | Php | Php-Extension | Size | Layers |
|-|-|-|-|-|
| `latest`, `stable`, `master` | 3.12 | | `fpm`, `curl`, `gmp`, `intl`, `mbstring`, `xml`, `zip`, `ctype`, `dom`, `fileinfo`, `iconv`, `gd`, `json`, `opcache`, `phar`, `session`, `simplexml`, `xmlreader`, `xmlwriter`, `tokenizer`, `zlib`, `mysqli `, `pdo_sqlit`, `pdo_mysql`, `pdo_pgsql` | ![](https://img.shields.io/docker/image-size/j33r/php-fpm/latest?style=flat-square) | ![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/j33r/php-fpm/latest?style=flat-square) |
| `dev`  | 3.12 | | same as master + `` | ![](https://img.shields.io/docker/image-size/j33r/php-fpm/dev?style=flat-square) | ![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/j33r/php-fpm/dev?style=flat-square) |
| `composer`  | 3.12 | | same as master + `symfony` | ![](https://img.shields.io/docker/image-size/j33r/php-fpm/dev?style=flat-square) | ![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/j33r/php-fpm/dev?style=flat-square) |
| `symfony`  | 3.12 | | same as master + `composer` + `symfony` | ![](https://img.shields.io/docker/image-size/j33r/php-fpm/dev?style=flat-square) | ![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/j33r/php-fpm/dev?style=flat-square) |

# What is PHP-FPM?

From [php.net](https://php.net):

>   PHP is a popular general-purpose scripting language that is especially suited to web development.
>   Fast, flexible and pragmatic, PHP powers everything from your blog to the most popular websites in the world.


# How to use these images

```bash
docker run \
    --detach \
    --interactive \
    --name php-fpm \
    --user $(id -u):$(id -g)
    --env TZ=Europe/Paris
    --volume /etc/localtime:/etc/localtime:ro
    j33r/php-fpm:latest
```    

## Volume mounts

- `/app`: the directory containing the application
- `/etc/php7/php-fpm.conf`: if you want overwrite default the [php-fpm.conf](https://www.php.net/manual/en/install.fpm.configuration.php)
- `/etc/php7/conf.d/00_custom.ini`: if you want overwrite default [php.ini config](https://www.php.net/manual/en/configuration.file.php)
- `/app/phpinfo.php` instead of running an application you can mount this file to get [php info](https://www.php.net/manual/en/function.phpinfo.php)
- `/php` the directory where php store the php-fpm.[pid](https://www.php.net/manual/en/install.fpm.configuration.php) and php-fpm.[socket](https://www.php.net/manual/en/install.fpm.configuration.php) files it's virtual volume so you can share it between container.

```bash
docker run \
    --detach \
    --interactive \
    --name php-fpm \
    --user $(id -u):$(id -g) \
    --volume /path/to/your/php-fpm.conf:/etc/php7/php-fpm.conf \
    --volume /path/to/your/php.ini:/etc/php7/conf.d/00_custom.ini \
    --volume /path/to/your/app:/app \
    --volume php:/php \
    --volume /etc/localtime:/etc/localtime:ro \
    j33r/php-fpm:latest
```

You should create directory before run the container otherwise directories are created by the docker deamon and owned by the root user

## Environment variables

To change the timezone of the container set the `TZ` environment variable. The full list of available options can be found on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

You can also set the `HOME` environment variable this is usefull to get in the right directory when you attach a shell in your docker container.



## Socket or ports

By default this image use `socket` protocol to bind `php-fpm` to a web-server ([apache](https://apache.org), [nginx](https://apache.org/)...). Socket file path is `/php/php-fpm.socket`
If you want use tcp protocol instead i need to overwrite `listen` value in [php-fpm.conf](https://www.php.net/manual/en/install.fpm.configuration.php) to `listen = 0.0.0.0:9000`

## Docker Compose (+ nginx)

[`docker-compose`](https://docs.docker.com/compose/) can help with defining the `docker run` config in a repeatable way rather than ensuring you always pass the same CLI arguments.

Here's an example `docker-compose.yml` config:

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
    image: j33r/nginx:latest
    user: "${UID:-1000}:${GID:-1000}"
    restart: unless-stopped
    volumes:
        - /etc/localtime:/etc/localtime:ro
        - ./nginx_default.conf:/etc/nginx/conf.d/default.conf
        - ./myapp:/app
        - php:/php
    ports:
        - "0.0.0.0:8080:8080"

volumes:
  php:
```

# License

This project is under the [GNU Generic Public License v3](https://github.com/jee-r/docker-php-fpm/blob/master/LICENSE) to allow free use while ensuring it stays open.
