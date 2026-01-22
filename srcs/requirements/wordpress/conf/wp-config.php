<?php

#define( 'DB_NAME', getenv('thedatabase') );
#define( 'DB_USER', getenv('theuser') );
#define( 'DB_PASSWORD', getenv('abc') );
#define( 'DB_HOST', getenv('mariadb') );
#define( 'WP_HOME', getenv('https://login.42.fr') );
#define( 'WP_SITEURL', getenv('https://login.42.fr') );

define( 'DB_NAME', getenv('DB_NAME') );
define('DB_USER', getenv('DB_USER') );
define('DB_PASSWORD', getenv('DB_PASSWORD') );
define('DB_HOST', getenv('DB_HOST') );
define('WP_HOME', getenv('WP_FULL_URL') );
define('WP_SITEURL', getenv('WP_FULL_URL') );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';