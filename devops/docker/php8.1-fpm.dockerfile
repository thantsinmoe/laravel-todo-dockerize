#Use PHP image
FROM php:8.1-fpm-alpine                     

#Label for description and not taking as layer
LABEL maintainer="Thant Sin Moe <thantsinmoe28@gmail.com>"
LABEL description="PHP 8.1 FPM Docker image for Laravel Deployment"

#Install additional PHP extensions and dependencies
RUN apk add-no-cache \
    libzip-dev \
    zip \
    unzip \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install pcntl \
    rm -rf /tmp/* /var/cache/apk/*

# Copy the PHP-FPM configuration file
ADD devops/docker/www.conf /usr/local/etc/php-fpm.d/www.conf

#Set the working directory
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate application key
RUN php artisan key:generate

# Run migrations and seed the database
RUN php artisan migrate --force && php artisan db:seed --force
