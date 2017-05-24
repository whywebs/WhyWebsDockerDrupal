#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

checkRq() {
    drush rq --format=json | jq ".\"${1}\".value" | grep -q "${2}"
    echo "OK"
}

checkStatus() {
    drush status --format=yaml | grep -q "${1}: ${2}"
    echo "OK"
}

runAction() {
    make "${@}" -f /usr/local/bin/actions.mk
}

if [[ -n "${DOCROOT_SUBDIR}" ]]; then
	DRUPAL_ROOT="${APP_ROOT}/${DOCROOT_SUBDIR}"
else
	DRUPAL_ROOT="${APP_ROOT}"
fi

echo -n "Checking environment variables... "
env | grep -q ^WODBY_DIR_CONF=
env | grep -q ^WODBY_DIR_FILES=
env | grep -q ^DOCROOT_SUBDIR=
env | grep -q ^DRUPAL_VERSION=
env | grep -q ^DRUPAL_SITE=
echo "OK"

DRUPAL_DOMAIN="$( echo "${WODBY_HOST_PRIMARY}" | sed 's/https\?:\/\///' )"
FILES_ARCHIVE_URL="https://s3.amazonaws.com/whywebs-sample-files/drupal-php-import-test/files.tar.gz"

composer create-project "drupal-composer/drupal-project:${DRUPAL_VERSION}.x-dev" "${APP_ROOT}" --stability dev --no-interaction
composer require drupal/redis

cd "${DRUPAL_ROOT}"

drush si -y --db-url="${DB_DRIVER}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}"
drush en redis -y --quiet
drush archive-dump -y --destination=/tmp/drush-archive.tar.gz
drush sql-drop -y

runAction drush-import source=/tmp/drush-archive.tar.gz
runAction files-import source="${FILES_ARCHIVE_URL}"
runAction init-drupal
runAction cache-clear target=render
runAction cache-rebuild

echo -n "Checking drupal console launcher... "
drupal -V --root=/var/www | grep -q "Launcher"
echo "OK"

echo -n "Checking drush version... "
checkStatus "drush-version" "8.*"

echo -n "Checking Drupal root... "
checkStatus "root" "${DRUPAL_ROOT}"

echo -n "Checking settings file... "
checkStatus "drupal-settings-file" "sites/${DRUPAL_SITE}/settings.php"

echo -n "Checking Drupal site path... "
checkStatus "site" "sites/${DRUPAL_SITE}"

echo -n "Checking Drupal file directory path... "
checkStatus "files" "sites/${DRUPAL_SITE}/files"

echo -n "Checking Drupal private file directory path... "
checkStatus "private" "${WODBY_DIR_FILES}/private"

echo -n "Checking Drupal temporary file directory path... "
checkStatus "temp" "/tmp"

echo -n "Checking Drupal sync config path... "
checkStatus "config-sync" "${WODBY_DIR_FILES}/config/sync_${DRUPAL_FILES_SYNC_SALT}"

echo -n "Checking redis connection... "
checkRq "redis" "Connected, using the <em>PhpRedis</em> client"

echo -n "Checking trusted host settings... "
checkRq "trusted_host_patterns" "Enabled"

echo -n "Checking Drupal file system permissions... "
checkRq "file system" "Writable (<em>public</em> download method)"

echo -n "Checking settings.php permissions... "
checkRq "configuration_files" "Protected"

echo -n "Checking trusted hosts... "
drush rq --format=yaml | grep "trusted_host_patterns setting" | \
    sed 's/\\n//g; s/\\\\//g; s/\^//g; s/\$//g; s/, /\//g' | grep -q "${WODBY_HOSTS}"
echo "OK"

echo -n "Checking imported files... "
curl -s -I -H "host: ${DRUPAL_DOMAIN}" "nginx/sites/default/files/logo.png" | grep -q "200 OK"
echo "OK"

echo -n "Checking Drupal homepage... "
curl -s -H "host: ${DRUPAL_DOMAIN}" "nginx" | grep -q "Drupal ${DRUPAL_VERSION} (https://www.drupal.org)"
echo "OK"
