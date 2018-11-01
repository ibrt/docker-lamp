FROM phusion/baseimage:0.11
MAINTAINER Ivan Bertona <ivan@ibrt.me>

# Customizable environment variables.
ENV PHP_VERSION=7.2
ENV MYSQL_VERSION=5.7
ENV PMA_VERSION=4.8.3
ENV COMPOSER_VERSION=1.7.2
ENV SERVER_NAME localhost
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_MODULES intl mysqli mbstring curl zip dom gd

# Inferred environment variables.
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES curl gettext git nano pwgen unzip apache2 libapache2-mod-php$PHP_VERSION mysql-server-$MYSQL_VERSION
ENV PMA_URL https://files.phpmyadmin.net/phpMyAdmin/$PMA_VERSION/phpMyAdmin-$PMA_VERSION-all-languages.tar.gz
ENV COMPOSER_URL https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar

# Set up filesystem and install packages.
RUN mkdir -p /etc/service/apache2 /etc/service/mysql /var/run/mysqld && \
    mkdir -p /usr/share/phpinfo /usr/share/docs /usr/share/phpmyadmin && \
    add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/apache2 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install $PACKAGES $(echo "$PHP_MODULES" | sed "s/[^ ]* */php$PHP_VERSION-&/g") && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R www-data:www-data /var/www && \
    curl --progress "$PMA_URL" | tar -xz -C /usr/share/phpmyadmin --strip-components 1 && \
	curl --progress "$COMPOSER_URL" > /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install support files.
ADD support/run_mysql.sh /etc/service/mysql/run
ADD support/run_apache2.sh /etc/service/apache2/run
ADD support/20_lampd.sh /etc/my_init.d/20_lampd.sh
ADD support/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD support/docs.php /usr/share/docs/index.php
ADD support/phpinfo.php /usr/share/phpinfo/index.php
ADD support/init.sql.tpl /usr/share/init.sql.tpl

# Configure packages.
RUN echo "ServerName $SERVER_NAME" >> /etc/apache2/apache2.conf && \
    sed -i "s#/var/www/#/project/app/#" /etc/apache2/apache2.conf && \
    a2enmod rewrite && \
    sed -i "s/^memory_limit.*/memory_limit = $PHP_MEMORY_LIMIT/" "/etc/php/$PHP_VERSION/apache2/php.ini" && \
    sed -i "s/^display_errors.*/display_errors = On/" "/etc/php/$PHP_VERSION/apache2/php.ini" && \
    sed -i "s/^display_startup_errors.*/display_startup_errors = On/" "/etc/php/$PHP_VERSION/apache2/php.ini" && \
    sed -i "s/^error_reporting.*/error_reporting = E_ALL/" "/etc/php/$PHP_VERSION/apache2/php.ini" && \
    sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i "s/.*datadir.*/datadir = \/project\/mysql/" /etc/mysql/mysql.conf.d/mysqld.cnf && \
    mv /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php && \
    sed -i "s/^\$cfg\['blowfish_secret'\].*/\$cfg['blowfish_secret'] = '$(pwgen -s 32 1)';/" /usr/share/phpmyadmin/config.inc.php && \
    echo "\$cfg['TempDir'] = '/tmp';" >> /usr/share/phpmyadmin/config.inc.php

# Configure image.
VOLUME [ "/project" ]
EXPOSE 80 3306
CMD ["/sbin/my_init"]