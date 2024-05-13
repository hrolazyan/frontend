FROM php:8.2-apache
WORKDIR /var/www/
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN a2enmod rewrite
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer