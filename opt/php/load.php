<?php

# Autoloads mu-plugins
# Turn off s3 upload plugin in the local environment
# so it doesn't rewrite media urls to an s3 address

if (getenv('WP_ENVIRONMENT_TYPE') != 'local') {
    require WPMU_PLUGIN_DIR .'/wp-s3-uploads/s3-uploads.php';
}
