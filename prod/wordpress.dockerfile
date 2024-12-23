# Stage 1: Build Composer artifacts
FROM composer:2 AS builder

# Set work directory
WORKDIR /app

# Copy composer files
COPY composer.json ./

# Pass build arguments for credentials
ARG COMPOSER_AUTH

# Set environment variables for Composer credentials
ENV COMPOSER_AUTH=${COMPOSER_AUTH}

# Install Composer dependencies
RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Stage 2: Base WordPress image
FROM --platform=linux/arm/v7 wordpress:6.6.1-php8.3-fpm-alpine

# Environment variables
ENV PHP_INI_DIR /usr/local/etc/php

# Install additional Alpine packages and wp-cli
RUN set -eux; \
    apk update && \
    apk add --no-cache less vim mysql-client htop libjpeg-turbo-utils && \
    curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    addgroup -g 1001 wp && \
    adduser -G wp -g "WordPress User" -s /bin/sh -D wp && \
    adduser wp www-data && \
    apk cache clean

# Add PHP multisite supporting files
COPY opt/php/load.php /usr/src/wordpress/wp-content/mu-plugins/load.php
COPY opt/php/application.php /usr/src/wordpress/wp-content/mu-plugins/application.php
COPY opt/php/error-handling.php /usr/src/wordpress/error-handling.php
COPY opt/php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY opt/php/wp-cron-multisite.php /usr/src/wordpress/wp-cron-multisite.php
COPY opt/php/php.ini $PHP_INI_DIR/conf.d/

# Setup WordPress multisite and network scripts
COPY opt/scripts/multisite-entrypoint.sh /usr/local/bin/multisite-entrypoint.sh
COPY opt/scripts/config.sh /usr/local/bin/config.sh

# Copy generated Composer artifacts and wp-content from the builder stage
COPY --from=builder /app/vendor /usr/src/wordpress/wp-content/vendor
COPY --from=builder /app/wordpress/wp-content/mu-plugins /usr/src/wordpress/wp-content/mu-plugins
COPY --from=builder /app/wordpress/wp-content/plugins /usr/src/wordpress/wp-content/plugins
COPY --from=builder /app/wordpress/wp-content/themes /usr/src/wordpress/wp-content/themes

# Create new user to run the container as non-root
RUN chown www-data:www-data /usr/local/bin/docker-entrypoint.sh

# Set permissions for scripts and WordPress content
RUN set -eux; \
    chmod +x /usr/local/bin/multisite-entrypoint.sh /usr/local/bin/config.sh && \
    mkdir -p /usr/src/wordpress/wp-content/uploads && \
    chown -R www-data:www-data /usr/src/wordpress/wp-content

# Overwrite official WP image ENTRYPOINT (docker-entrypoint.sh)
ENTRYPOINT ["/usr/local/bin/multisite-entrypoint.sh"]

# Run as non-root user
USER www-data
