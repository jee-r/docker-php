FROM php:7-fpm-alpine3.14

LABEL name="docker-php-fpm" \
      maintainer="Jee jee@jeer.fr" \
      description="PHP is a popular general-purpose scripting language that is especially suited to web development." \
      url="https://www.php.net" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-php-fpm"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    sync && \
    apk add --virtual=base --upgrade --no-cache \
      git \
      bash \
      tzdata && \
    /usr/local/bin/install-php-extensions \
      gmp \
      intl \
      zip \
      opcache \
      mysqli \
      pdo_pgsql \
      pdo_mysql && \
    mkdir -p /php && \
    mkdir -p /app && \
    chmod -R 777 /app /php

WORKDIR /app

STOPSIGNAL SIGQUIT
VOLUME ["/php", "/app"]
