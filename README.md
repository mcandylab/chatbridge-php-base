# chatbridge-php-base

Базовые образы PHP 8.5 (alpine) с расширениями ChatBridge: bcmath, exif, gd, gmp,
intl, pcntl, pdo_pgsql, pgsql, sockets, zip, phpredis. Секретов и кода приложения здесь нет.

- `ghcr.io/<owner>/chatbridge-php:8.5-cli` — воркеры (Horizon, scheduler, Reverb)
- `ghcr.io/<owner>/chatbridge-php:8.5-fpm` — веб (php-fpm)

Сборка запускается пушем в `main`, вручную и раз в месяц (свежие security-патчи php-образа).
