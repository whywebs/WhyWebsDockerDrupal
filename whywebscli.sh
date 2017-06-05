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

drush uli --uri="http://whywebs.dev"