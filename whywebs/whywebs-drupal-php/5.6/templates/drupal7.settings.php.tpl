<?php
/**
 * @file
 * Wodby environment configuration for Drupal 7.
 */

$whywebs['files_dir'] = '{{ getenv "WODBY_DIR_FILES" }}';
$whywebs['base_url'] = '{{ getenv "WODBY_HOST_PRIMARY" "" }}';

$whywebs['site'] = '{{ getenv "DRUPAL_SITE" }}';
$whywebs['hash_salt'] = '{{ getenv "DRUPAL_HASH_SALT" "" }}';

$whywebs['db']['host'] = '{{ getenv "DB_HOST" "" }}';
$whywebs['db']['name'] = '{{ getenv "DB_NAME" "" }}';
$whywebs['db']['username'] = '{{ getenv "DB_USER" "" }}';
$whywebs['db']['password'] = '{{ getenv "DB_PASSWORD" "" }}';
$whywebs['db']['driver'] = '{{ getenv "DB_DRIVER" "mysql" }}';

$whywebs['varnish']['host'] = '{{ getenv "VARNISH_HOST" "" }}';
$whywebs['varnish']['terminal_port'] = '{{ getenv "VARNISH_SERVICE_PORT_6082" "6082" }}';
$whywebs['varnish']['secret'] = '{{ getenv "VARNISH_SECRET" "" }}';
$whywebs['varnish']['version'] = '{{ getenv "VARNISH_VERSION" "4" }}';

$whywebs['redis']['host'] = '{{ getenv "REDIS_HOST" "" }}';
$whywebs['redis']['port'] = '{{ getenv "REDIS_SERVICE_PORT" "6379" }}';
$whywebs['redis']['password'] = '{{ getenv "REDIS_PASSWORD" "" }}';

if (isset($_SERVER['HTTP_X_REAL_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_REAL_IP'];
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
}

if (!isset($base_url) && !empty($whywebs['base_url'])) {
  $base_url = $whywebs['base_url'];
}

if (!isset($update_free_access)) {
  $update_free_access = FALSE;
}

if (empty($drupal_hash_salt)) {
  $drupal_hash_salt = $whywebs['hash_salt'];
}

if (!isset($conf['404_fast_html'])) {
  $conf['404_fast_paths_exclude'] = '/\/(?:styles)\//';
  $conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
  $conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';
}

if (!empty($whywebs['db']['host'])) {
  if (!isset($databases['default']['default'])) {
    $databases['default']['default'] = [];
  }

  $databases['default']['default'] = array_merge(
    $databases['default']['default'],
    [
      'host' => $whywebs['db']['host'],
      'database' => $whywebs['db']['name'],
      'username' => $whywebs['db']['username'],
      'password' => $whywebs['db']['password'],
      'driver' => $whywebs['db']['driver'],
    ]
  );
}

$conf['file_public_path'] = "sites/{$whywebs['site']}/files";
$conf['file_private_path'] = $whywebs['files_dir'] . '/private';
$conf['file_temporary_path'] = '/tmp';

if (!defined('MAINTENANCE_MODE') || MAINTENANCE_MODE != 'install') {
  $site_mods_dir = "sites/{$whywebs['site']}/modules";
  $contrib_path = is_dir('sites/all/modules/contrib') ? 'sites/all/modules/contrib' : 'sites/all/modules';
  $contrib_path_site = is_dir("$site_mods_dir/contrib") ? "$site_mods_dir/contrib" : $site_mods_dir;

  $varnish_module_exists = file_exists("$contrib_path/varnish") || file_exists("$contrib_path_site/varnish");

  if (!empty($whywebs['varnish']['host']) && $varnish_module_exists) {
    $conf['varnish_version'] = $whywebs['varnish']['version'];
    $conf['varnish_control_terminal'] = $whywebs['varnish']['host'] . ':' . $whywebs['varnish']['terminal_port'];
    $conf['varnish_control_key'] = $whywebs['varnish']['secret'];
  }

  $redis_module_path = NULL;

  if (file_exists("$contrib_path/redis")) {
    $redis_module_path = "$contrib_path/redis";
  } elseif (file_exists("$contrib_path_site/redis")) {
    $redis_module_path = "$contrib_path_site/redis";
  }

  if (!empty($whywebs['redis']['host']) && $redis_module_path) {
    $conf['redis_client_host'] = $whywebs['redis']['host'];
    $conf['redis_client_port'] = $whywebs['redis']['port'];
    $conf['redis_client_password'] = $whywebs['redis']['password'];
    $conf['redis_client_base'] = 0;
    $conf['redis_client_interface'] = 'PhpRedis';
    $conf['cache_backends'][] = "$redis_module_path/redis.autoload.inc";
    $conf['cache_default_class'] = 'Redis_Cache';
    $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
    $conf['lock_inc'] = "$redis_module_path/redis.lock.inc";
    $conf['path_inc'] = "$redis_module_path/redis.path.inc";
  }
}

ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
ini_set('pcre.backtrack_limit', 200000);
ini_set('pcre.recursion_limit', 200000);