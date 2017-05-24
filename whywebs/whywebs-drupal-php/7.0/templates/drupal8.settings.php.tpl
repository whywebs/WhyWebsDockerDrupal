<?php
/**
 * @file
 * Wodby environment configuration for Drupal 8.
 */

{{ $hosts := split (getenv "WODBY_HOSTS" "" ) "/" }}{{ range $hosts }}
$whywebs['hosts'][] = '{{ . }}';
{{ end }}

$whywebs['files_dir'] = '{{ getenv "WODBY_DIR_FILES" }}';
$whywebs['site'] = '{{ getenv "DRUPAL_SITE" }}';
$whywebs['hash_salt'] = '{{ getenv "DRUPAL_HASH_SALT" "" }}';
$whywebs['sync_salt'] = '{{ getenv "DRUPAL_FILES_SYNC_SALT" "" }}';

$whywebs['db']['host'] = '{{ getenv "DB_HOST" "" }}';
$whywebs['db']['name'] = '{{ getenv "DB_NAME" "" }}';
$whywebs['db']['username'] = '{{ getenv "DB_USER" "" }}';
$whywebs['db']['password'] = '{{ getenv "DB_PASSWORD" "" }}';
$whywebs['db']['driver'] = '{{ getenv "DB_DRIVER" "mysql" }}';

$whywebs['redis']['host'] = '{{ getenv "REDIS_HOST" "" }}';
$whywebs['redis']['port'] = '{{ getenv "REDIS_SERVICE_PORT" "6379" }}';
$whywebs['redis']['password'] = '{{ getenv "REDIS_PASSWORD" "" }}';

if (isset($_SERVER['HTTP_X_REAL_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_REAL_IP'];
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
}

if (empty($settings['container_yamls'])) {
  $settings['container_yamls'][] = "sites/{$whywebs['site']}/services.yml";
}

if (!array_key_exists('update_free_access', $settings)) {
  $settings['update_free_access'] = FALSE;
}

if (empty($settings['hash_salt'])) {
  $settings['hash_salt'] = $whywebs['hash_salt'];
}

if (!array_key_exists('file_scan_ignore_directories', $settings)) {
  $settings['file_scan_ignore_directories'] = [
    'node_modules',
    'bower_components',
  ];
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

$settings['file_public_path'] = "sites/{$whywebs['site']}/files";
$settings['file_private_path'] = $whywebs['files_dir'] . '/private';
$settings['file_temporary_path'] = '/tmp';

$config_directories['sync'] = $whywebs['files_dir'] . '/config/sync_' . $whywebs['sync_salt'];

if (!empty($whywebs['hosts'])) {
  foreach ($whywebs['hosts'] as $host) {
    $settings['trusted_host_patterns'][] = '^' . str_replace('.', '\.', $host) . '$';
  }
}

if (!defined('MAINTENANCE_MODE') || MAINTENANCE_MODE != 'install') {
  $site_mods_dir = "sites/{$whywebs['site']}/modules";
  $contrib_path = is_dir('modules/contrib') ? 'modules/contrib' : 'modules';
  $contrib_path_site = is_dir("$site_mods_dir/contrib") ? "$site_mods_dir/contrib" : $site_mods_dir;

  $redis_module_path = NULL;

  if (file_exists("$contrib_path/redis")) {
    $redis_module_path = "$contrib_path/redis";
  } elseif (file_exists("$contrib_path_site/redis")) {
    $redis_module_path = "$contrib_path_site/redis";
  }

  if (!empty($whywebs['redis']['host']) && $redis_module_path) {
    $settings['redis.connection']['host'] = $whywebs['redis']['host'];
    $settings['redis.connection']['port'] = $whywebs['redis']['port'];
    $settings['redis.connection']['password'] = $whywebs['redis']['password'];
    $settings['redis.connection']['base'] = 0;
    $settings['redis.connection']['interface'] = 'PhpRedis';
    $settings['cache']['default'] = 'cache.backend.redis';
    $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
    $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
    $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';

    $settings['container_yamls'][] = "$redis_module_path/example.services.yml";
  }
}
