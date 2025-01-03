#!/bin/bash

# Exit script if any command fails
set -e

# Multisite and WordPress settings
wp config set MULTISITE true --raw --allow-root
wp config set WP_ALLOW_MULTISITE true --raw --allow-root
wp config set BLOG_ID_CURRENT_SITE 1 --raw --allow-root
wp config set SITE_ID_CURRENT_SITE 1 --raw --allow-root
wp config set SUBDOMAIN_INSTALL false --raw --allow-root
wp config set DOMAIN_CURRENT_SITE "$SERVER_NAME" --raw --allow-root
wp config set COOKIE_DOMAIN false --raw --allow-root
wp config set ADMIN_COOKIE_PATH "/" --allow-root
wp config set COOKIEPATH "/" --allow-root
wp config set SITECOOKIEPATH "/" --allow-root
wp config set WP_ENVIRONMENT_TYPE "$WP_ENVIRONMENT_TYPE" --raw --allow-root

# S3 settings for uploads
wp config set S3_UPLOADS_BUCKET "$S3_UPLOADS_BUCKET" --raw --allow-root
wp config set S3_UPLOADS_REGION "$S3_UPLOADS_REGION" --raw --allow-root
wp config set S3_UPLOADS_KEY "$S3_UPLOADS_KEY" --raw --allow-root
wp config set S3_UPLOADS_SECRET "$S3_UPLOADS_SECRET" --raw --allow-root
wp config set S3_UPLOADS_USE_INSTANCE_PROFILE "$S3_UPLOADS_USE_INSTANCE_PROFILE" --raw --allow-root

# Performance and security settings
wp config set AUTOMATIC_UPDATER_DISABLED true --raw --allow-root
wp config set FORCE_SSL_ADMIN false --raw --allow-root
wp config set QM_ENABLE_CAPS_PANEL true --raw --allow-root
wp config set WP_CACHE true --raw --allow-root
wp config set WP_TIMEZONE 'Europe/London' --raw --allow-root
wp config set MYSQL_CLIENT_FLAGS 0 --raw --allow-root

# WP core install
wp core multisite-install --title="WordPress MS Build" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --url="${SERVER_NAME}" \
    --skip-config \
    --skip-email \
    --quiet --allow-root;

# Run DB check and update for multisite
wp core update-db --network --url="${SERVER_NAME}" --allow-root

# Clean up default themes (if needed)
wp theme delete twentytwentythree --allow-root

exec "$@"
