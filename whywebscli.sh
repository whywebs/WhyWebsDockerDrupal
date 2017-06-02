#!/bin/sh

drush si -y

drush vset site_name 'Whywebs Docker Drupal Site' -y

# Enable page caching so we can demonstrate Varnish
drush vset cache 1 -y

drush en search_api_solr -y
