# syntax=docker/dockerfile:1

# Базовый образ PHP с расширениями, которые нужны приложению.
# Расширения компилируются ~20 минут, поэтому они собираются здесь один раз,
# а образы приложения просто берут этот как FROM.
#
# Варианты: cli (воркеры) и fpm (веб).

ARG PHP_VERSION=8.5
ARG VARIANT=cli

FROM php:${PHP_VERSION}-${VARIANT}-alpine

COPY install-php-extensions.sh /tmp/install-php-extensions.sh
RUN sh /tmp/install-php-extensions.sh && rm /tmp/install-php-extensions.sh

RUN apk add --no-cache su-exec tzdata
