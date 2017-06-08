#!/bin/sh

# Enable page caching so we can demonstrate Varnish
touch ~/.ssh/config

echo "HostkeyAlgorithms +ssh-dss" >> ~/.ssh/config

chmod 600 ~/.ssh/config

drush sql-drop -y

drush site-install --db-url=mysql://root:whywebs@192.168.99.100/whywebs -y --account-name=admin --account-pass=admin --site-mail=sam@whywebs.com --account-mail=sam@whywebs.com --clean-url=1 --site-name=Whywebs

drush en aggregator blog contact multistep_registration token menu_attributes menu_token rules rules_ui search_api  media entity migrate poll statistics syslog logintoboggan tracker trigger views views_ui admin_menu features -y

drush pm-disable update toolbar -y

chmod -Rv 777 sites/default/files

mkdir /tmp

chmod -Rv 777 /tmp

if [ ! -f /etc/phpmyadmin/config.secret.inc.php ] ; then
    cat > /etc/phpmyadmin/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '$(tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' < /dev/urandom | fold -w 32 | head -n 1)';
EOT
fi

if [ ! -f /etc/phpmyadmin/config.user.inc.php ] ; then
  touch /etc/phpmyadmin/config.user.inc.php
fi

find /var/www/html -iname '*.txt' -not -path '*features*' -not -path '*test*' -not -path '*context*' -not -path '*whywebs.txt' -not -path '*zen*' -not -name 'robots.txt' -print -delete

mkdir -p /var/nginx/client_body_temp
chown nobody:nobody /sessions /var/nginx/client_body_temp
mkdir -p /var/run/php/
chown nobody:nobody /var/run/php/
touch /var/log/php-fpm.log
chown nobody:nobody /var/log/php-fpm.log

if [ "$1" = 'phpmyadmin' ]; then
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info
fi

# fixing our settings file after installation by drush

echo "$conf['file_temporary_path'] = '/tmp';" >> sites/default/settings.php
echo "$conf['cache'] = 0;" >> sites/default/settings.php
echo "$conf['preprocess_css'] = FALSE;" >> sites/default/settings.php
echo "$conf['preprocess_js'] = FALSE;" >> sites/default/settings.php
echo "$conf['css_gzip_compression'] = FALSE;" >> sites/default/settings.php
echo "$conf['js_gzip_compression'] = FALSE;" >> sites/default/settings.php
echo "$cookie_domain = '.whywebs.site';" >> sites/default/settings.php
echo "$base_url = 'http://whywebs.site';" >> sites/default/settings.php

