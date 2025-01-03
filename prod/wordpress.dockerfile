# Base WordPress image
FROM wordpress:6.7.1-php8.3-fpm-alpine

# Environment variables
ENV PHP_INI_DIR=/usr/local/etc/php

# Install additional Alpine packages and wp-cli
RUN set -eux; \
    apk update && \
    apk add --no-cache less vim mariadb-client mariadb-backup htop libjpeg-turbo-utils && \
    curl -o /usr/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/bin/wp && \
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
COPY /vendor /usr/src/wordpress/wp-content/vendor
COPY /wordpress/wp-content/mu-plugins /usr/src/wordpress/wp-content/mu-plugins
COPY /wordpress/wp-content/plugins /usr/src/wordpress/wp-content/plugins
COPY /wordpress/wp-content/themes /usr/src/wordpress/wp-content/themes

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
