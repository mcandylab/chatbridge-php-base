#!/bin/sh
# Устанавливает PHP-расширения, необходимые приложению.
# Используется всеми образами (php-fpm и cli), поэтому слой кэшируется между ними.
set -eux

# opcache в списке отсутствует намеренно: в официальных образах php он уже вкомпилирован
# в бинарник статически. Попытка собрать его через phpize даёт пустой modules/ и падает.
# Достаточно ini-настроек — см. docker/common/opcache.ini.
PHP_EXTENSIONS="
    bcmath
    exif
    gd
    gmp
    intl
    pcntl
    pdo_pgsql
    pgsql
    sockets
    zip
"

BUILD_DEPS="
    autoconf
    freetype-dev
    g++
    gcc
    gmp-dev
    icu-dev
    libc-dev
    libjpeg-turbo-dev
    libpng-dev
    libpq-dev
    libzip-dev
    linux-headers
    make
    pkgconf
    re2c
"

RUNTIME_DEPS="
    freetype
    gmp
    icu-data-full
    icu-libs
    libgomp
    libjpeg-turbo
    libpng
    libpq
    libzip
"

apk add --no-cache --virtual .php-build-deps $BUILD_DEPS
apk add --no-cache $RUNTIME_DEPS

docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j"$(nproc)" $PHP_EXTENSIONS

# phpredis собираем из исходников, а не через `pecl install`: тот ходит за метаданными
# в REST API pecl.php.net, который доступен не из всякой сети (деплой падал на
# `Package "redis" does not have REST info xml available`). Основной источник — GitHub,
# запасной — прямая ссылка на тот же тарбол у pecl, минуя REST.
PHPREDIS_VERSION=6.3.0

mkdir -p /tmp/phpredis
curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 -o /tmp/phpredis.tgz \
        "https://github.com/phpredis/phpredis/archive/refs/tags/${PHPREDIS_VERSION}.tar.gz" \
    || curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 -o /tmp/phpredis.tgz \
        "https://pecl.php.net/get/redis-${PHPREDIS_VERSION}.tgz"
tar -xzf /tmp/phpredis.tgz -C /tmp/phpredis --strip-components=1

cd /tmp/phpredis
phpize
./configure
make -j"$(nproc)"
make install
docker-php-ext-enable redis

cd /
rm -rf /tmp/phpredis /tmp/phpredis.tgz

apk del --no-network .php-build-deps
rm -rf /usr/local/lib/php/doc /usr/local/lib/php/test
