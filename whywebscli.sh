#!/bin/sh

# Enable page caching so we can demonstrate Varnish

touch ~/.ssh/config

echo "HostkeyAlgorithms +ssh-dss" >> ~/.ssh/config

chmod 600 ~/.ssh/config

drush si standard --db-url='mysql://whywebs:whywebs@192.168.99.100/whywebs' --site-name="Whywebs Docker Drupal" -y --account-name="admin" --account-pass="whywebs"

drush vset cache 1 -y

drush en views token search_api admin_menu features search_api_solr -y

drush pm-disable toolbar -y

chmod -Rv 777 sites/default/files

drush uli --uri="http://local.dev"

# PHPadmiInstall

if [ ! -f /etc/phpmyadmin/config.secret.inc.php ] ; then
    cat > /etc/phpmyadmin/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '$(tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' < /dev/urandom | fold -w 32 | head -n 1)';
EOT
fi

if [ ! -f /etc/phpmyadmin/config.user.inc.php ] ; then
  touch /etc/phpmyadmin/config.user.inc.php
fi

mkdir -p /var/nginx/client_body_temp
chown nobody:nobody /sessions /var/nginx/client_body_temp
mkdir -p /var/run/php/
chown nobody:nobody /var/run/php/
touch /var/log/php-fpm.log
chown nobody:nobody /var/log/php-fpm.log

if [ "$1" = 'phpmyadmin' ]; then
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info
fi