#!/bin/bash

# Define settings in wp-config.php
wp config set MULTISITE true --raw
wp config set WP_ALLOW_MULTISITE true --raw
wp config set BLOG_ID_CURRENT_SITE 1 --raw
wp config set SITE_ID_CURRENT_SITE 1 --raw
wp config set SUBDOMAIN_INSTALL false --raw
wp config set DOMAIN_CURRENT_SITE "\$_SERVER['SERVER_NAME']" --raw
wp config set COOKIE_DOMAIN false --raw
wp config set ADMIN_COOKIE_PATH "/"
wp config set COOKIEPATH "/"
wp config set SITECOOKIEPATH "/"
wp config set WP_ENVIRONMENT_TYPE "\$_SERVER['WP_ENVIRONMENT_TYPE']" --raw
wp config set AUTOMATIC_UPDATER_DISABLED true --raw
wp config set FORCE_SSL_ADMIN false --raw
wp config set S3_UPLOADS_BUCKET "\$_SERVER['S3_UPLOADS_BUCKET']" --raw
wp config set S3_UPLOADS_REGION "\$_SERVER['S3_UPLOADS_REGION']" --raw
wp config set S3_UPLOADS_KEY "\$_SERVER['S3_UPLOADS_KEY']" --raw
wp config set S3_UPLOADS_SECRET "\$_SERVER['S3_UPLOADS_SECRET']" --raw
wp config set S3_UPLOADS_USE_INSTANCE_PROFILE "\$_SERVER['S3_UPLOADS_USE_INSTANCE_PROFILE']" --raw
wp config set QM_ENABLE_CAPS_PANEL true --raw
wp config set WP_CACHE true --raw

#WP core install
wp core multisite-install --title="Ox-Build Multisite Platform" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --url="${SERVER_NAME}" \
    --skip-config \
    --skip-email \
    --quiet;

# Run DB check and update
wp core update-db --network --url="${SERVER_NAME}"

# Activate greater capabilities for Query Monitor plugin
#wp qm enable

# Delete default installed core themes and plugins
#wp theme delete twentytwentyone twentytwentytwo

exec "$@"
