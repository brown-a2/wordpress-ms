#!/bin/bash

# Exit script if any command fails
set -e

# 1. **Multisite Configuration**
# Set up the WordPress multisite configuration and define current site settings
wp config set MULTISITE true --raw
wp config set WP_ALLOW_MULTISITE true --raw
wp config set BLOG_ID_CURRENT_SITE 1 --raw
wp config set SITE_ID_CURRENT_SITE 1 --raw
wp config set SUBDOMAIN_INSTALL false --raw
wp config set DOMAIN_CURRENT_SITE "\$_SERVER['SERVER_NAME']" --raw

# 2. **Cookie and Path Settings**
# Configure cookie settings for WordPress to manage user sessions and paths
wp config set COOKIE_DOMAIN false --raw
wp config set ADMIN_COOKIE_PATH "/"
wp config set COOKIEPATH "/"
wp config set SITECOOKIEPATH "/"

# 3. **Environment and Update Settings**
# Define environment type and manage automatic updates and SSL settings for admin
wp config set WP_ENVIRONMENT_TYPE "\$_SERVER['WP_ENVIRONMENT_TYPE']" --raw
wp config set AUTOMATIC_UPDATER_DISABLED true --raw
wp config set FORCE_SSL_ADMIN false --raw

# 4. **S3 Uploads Configuration**
# Configure the S3 settings for uploads, including the bucket, region, and access credentials
wp config set S3_UPLOADS_BUCKET "\$_SERVER['S3_UPLOADS_BUCKET']" --raw
wp config set S3_UPLOADS_REGION "\$_SERVER['S3_UPLOADS_REGION']" --raw
wp config set S3_UPLOADS_KEY "\$_SERVER['S3_UPLOADS_KEY']" --raw
wp config set S3_UPLOADS_SECRET "\$_SERVER['S3_UPLOADS_SECRET']" --raw
wp config set S3_UPLOADS_USE_INSTANCE_PROFILE "\$_SERVER['S3_UPLOADS_USE_INSTANCE_PROFILE']" --raw

# 5. **Performance and Debugging Settings**
# Enable Query Monitor capabilities and configure caching
wp config set QM_ENABLE_CAPS_PANEL true --raw
wp config set WP_CACHE true --raw

# 6. **Timezone and Database Settings**
# Set the timezone for WordPress to "Europe/London" and disable SSL for database connections
wp config set WP_TIMEZONE "Europe/London" --raw
wp config set MYSQL_CLIENT_FLAGS 0 --raw

#WP core install
wp core multisite-install --title="WordPress MS Build" \
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
wp qm enable

# Delete default installed core themes and plugins
wp theme delete twentytwentythree

exec "$@"
