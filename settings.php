<?php

include dirname(__FILE__) . '/../default/default.settings.php';

$databases['default'] = [
  'default' => [
    'driver' => 'mysql',
    'database' => 'drupal',
    'username' => 'root',
    'password' => 'root',
    'host' => 'mysql',
    'prefix' => '',
    'collation' => 'utf8_general_ci',
  ],
];

$conf['redis_client_interface'] = 'PhpRedis';
$conf['cache_backends'] = [
  'sites/all/modules/contrib/redis/redis.autoload.inc',
];
$conf['cache_default_class'] = 'Redis_Cache';
$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
$conf['lock_inc'] = 'sites/all/modules/contrib/redis/redis.lock.inc';
$conf['redis_client_host'] = 'redis';
$conf['redis_client_port'] = '6379';
$conf['redis_client_base'] = '0';
$conf['redis_client_password'] = '';