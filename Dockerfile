FROM php:5.6.30-apache
MAINTAINER Mutasem Elayyoub "melayyoub@outlook.com"

# enviroment YOU CAN CHANGE THIS ENV DEPENDING ON WHAT YOU NEED YOUR ADMIN AND PASSWORD
#To change this please make sure to change the compose mariaDB too
ENV WHYWEBS_DB whywebs 
ENV WHYWEBS_DB_PASS whywebs 
ENV WHYWEBS_DB_ADMIN whywebs 

#To change this please make sure to change the compose mariaDB too
ENV WHYWEBS_PASS whywebs 
ENV WHYWEBS_USER whywebs
ENV WHYWEBS_WEB_NAME Whywebs Docker Drupal

# DONNOT CHANGE THE HOST BELOW
ENV WHYWEBS_DB_HOST 192.168.99.100:3306

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
	&& apt-get install -y unzip nginx apache2 apache2-utils wget curl git nano \ 
	&& apt-get install php5-mysql php5-gd php5-curl php-pear gcc php5-imagick php5-mcrypt php5-memcache -y \
	&& apt-get install -y \
	    bzip2 \
	    libbz2-dev \
	    libc-client2007e-dev \
	    libjpeg-dev \
	    libkrb5-dev \
	    libldap2-dev \
	    libpcre3-dev \
	    libmagickwand-dev \
	    libmcrypt-dev \
	    libpng12-dev \
	    libpq-dev \
	    libxml2-dev \
	    mysql-client \
	    imagemagick \
	    xfonts-base \
	    xfonts-75dpi \
	&& docker-php-ext-install \
	    bcmath \
	    bz2 \
	    calendar \
	    gd \
	    mcrypt \
	    mbstring \
	    mysqli \
	    opcache \
	    pdo \
	    pdo_mysql \
	    soap \
	    zip \
  	&& pecl install imagick \
	&& pecl search xdebug \
	&& pecl install xdebug-beta \
	&& git clone git://github.com/xdebug/xdebug.git \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
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
    && apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* && rm -rf && rm -rf /var/lib/cache/* && rm -rf /var/lib/log/* && rm -rf /tmp/* \
    && chmod 600 /etc/mysql/my.cnf 

COPY ./whywebs-drupal/php.ini /usr/local/etc/php/conf.d
COPY ./whywebs-drupal/whywebs.dev.conf /etc/apache2/sites-enabled	
COPY ./deploy /var/www/html
COPY ./config/mysql /etc/mysql
COPY ./config/drush /home/root/.drush
COPY ./config/nginx /etc/nginx

RUN service apache2 restart \
	&& cd /var/www/html \
	&& drush site-install standard --db-url='mysql://$(WHYWEBS_DB_ADMIN):$(WHYWEBS_DB_PASS)@$(WHYWEBS_DB_HOST)/$(WHYWEBS_DB)' --site-name=$(WHYWEBS_WEB_NAME) -y --account-name=$(WHYWEBS_ADMIN) --account-pass=$(WHYWEBS_PASS)

RUN ln -sf ./logs /var/log/nginx/access.log \
    && ln -sf ./logs /var/log/nginx/error.log

EXPOSE 80
WORKDIR /var/www/html
