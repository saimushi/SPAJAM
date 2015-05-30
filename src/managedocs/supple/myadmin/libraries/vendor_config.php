<?php
/* vim: set expandtab sw=4 ts=4 sts=4: */
/**
 * File for vendor customisation, you can change here paths or some behaviour,
 * which vendors such as Linux distibutions might want to change.
 *
 * For changing this file you should know what you are doing. For this reason
 * options here are not part of normal configuration.
 *
 * @package PhpMyAdmin
 */
if (! defined('PHPMYADMIN')) {
    exit;
}

/**
 * Path to changelog file, can be gzip compressed. Useful when you want to
 * have documentation somewhere else, eg. /usr/share/doc.
 */
define('CHANGELOG_FILE', '/usr/share/doc/phpMyAdmin-4.0.4/ChangeLog');

/**
 * Path to license file. Useful when you want to have documentation somewhere
 * else, eg. /usr/share/doc.
 */
define('LICENSE_FILE', '/usr/share/doc/phpMyAdmin-4.0.4/LICENSE');

/**
 * Path to config file generated using setup script.
 */
define('SETUP_CONFIG_FILE', dirname(dirname(__FILE__)).'/config.inc.php');

/**
 * Whether setup requires writable directory where config
 * file will be generated.
 */
define('SETUP_DIR_WRITABLE', true);

/**
 * Directory where configuration files are stored.
 * It is not used directly in code, just a convenient
 * define used further in this file.
 */
define('CONFIG_DIR', dirname(dirname(__FILE__)).'/');

/**
 * Filename of a configuration file.
 */
define('CONFIG_FILE', CONFIG_DIR . 'config.inc.php');

/**
 * Filename of custom header file.
 */
define('CUSTOM_HEADER_FILE', CONFIG_DIR . 'config.header.inc.php');

/**
 * Filename of custom footer file.
 */
define('CUSTOM_FOOTER_FILE', CONFIG_DIR . 'config.footer.inc.php');

/**
 * Default value for check for version upgrades.
 */
define('VERSION_CHECK_DEFAULT', true);

/**
 * Path to gettext.inc file. Useful when you want php-gettext somewhere else,
 * eg. /usr/share/php/gettext/gettext.inc.
 */
define('GETTEXT_INC', './libraries/php-gettext/gettext.inc');

/**
 * Path to tcpdf.php file. Useful when you want to use system tcpdf,
 * eg. /usr/share/php/tcpdf/tcpdf.php.
 */
define('TCPDF_INC', '/usr/share/php/tcpdf/tcpdf.php');
?>
