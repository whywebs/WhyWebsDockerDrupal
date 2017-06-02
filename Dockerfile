FROM php:5.6.30-apache
MAINTAINER Mutasem Elayyoub "melayyoub@outlook.com"

# install the PHP extensions we need
RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
    && mkdir -p xcache \
    && tar -xf xcache.tar.gz -C xcache --strip-components=1 \
    && rm xcache.tar.gz \
    && ( \
        cd xcache \
        && phpize \
        && ./configure --enable-xcache \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r xcache \
    && docker-php-ext-enable xcache

RUN set -ex \
	&& apt-get update -y \
	&& apt-get upgrade -y && apt-get dist-upgrade -y \
	&& apt-cache search php5 \
	&& apt-get install -y unzip && apt-get install -y wget && apt-get install -y curl && apt-get install -y git  && apt-get install apache2 apache2-utils -y && apt-get install nano -y \
	&& apt-get install php5-mysql php5-curl php5-gd php5-intl php-pear gcc libpcre3-dev php5-imagick php5-imap php5-mcrypt php5-memcache php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl software-properties-common -y \
	&& apt-get install php-soap -y \	
	&& apt-get install -y nginx \
	&& pecl search xdebug \
	&& pecl install xdebug-beta \
	&& git clone git://github.com/xdebug/xdebug.git \
	&& curl -s https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer global require drush/drush:8.* \
	&& export PATH="$HOME/.config/composer/vendor/bin:$PATH" \
	&& apt-get install drush -y \
	&& php -m \
	&& echo 'xdebug.show_error_trace = 1' /etc/php/5.6/mods-available/xdebug.ini \
	&& echo 'ServerName localhost' >> /etc/apache2/apache2.conf \
	&& chmod -R 755 /var/www/html \
	&& echo '127.0.0.1   whywebs.dev' >> /etc/hosts \
	&& echo "<IfModule mod_dir.c>" >> /etc/apache2/mods-enabled/dir.conf \
	&& echo " DirectoryIndex index.php index.html index.cgi index.pl index.php index.xhtml index.htm" >> /etc/apache2/mods-enabled/dir.conf \
	&& echo " </IfModule>" >> /etc/apache2/mods-enabled/dir.conf \
	&& service apache2 restart 

COPY ./whywebs-drupal/php.ini /usr/local/etc/php/conf.d
COPY ./whywebs-drupal/whywebs.dev.conf /etc/apache2/sites-enabled	
COPY ./deploy /var/www/html
COPY ./config/mysql /etc/mysql
COPY ./config/drush /home/root/.drush
COPY ./config/nginx /etc/nginx

RUN ln -sf ./logs /var/log/nginx/access.log \
    && ln -sf ./logs /var/log/nginx/error.log

EXPOSE 80
WORKDIR /var/www/html
