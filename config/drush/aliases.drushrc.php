<?php
/**
 * This file is automatically updated by kalabox-plugin-drush.
 */
$aliases['whwyebs'] = array(
  'uri' => 'localhost',
  'root' => '/var/www/html',
  'databases' =>
    array (
      'default' =>
        array (
          'default' =>
            array (
              'driver' => 'mysql',
              'username' => 'root',
              'password' => 'root',
              'port' => 3306,
              'host' => getenv('MYSQL_HOST'),
              'database' => 'whywebsdockerdrupal',
            ),
        ),
    ),
);
