FROM phusion/baseimage:0.11
MAINTAINER Ivan Bertona <ivan@ibrt.me>

# Environment variables.
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES install curl gettext nano pwgen apache2 libapache2-mod-php php-intl mysql-server composer phpmyadmin 
ENV SERVER_NAME localhost
ENV PHP_MEMORY_LIMIT 256M

# Install packages.
RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/apache2 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y $PACKAGES && \
    apt-get -y autoremove

# Create folders and copy support files.
RUN mkdir -p /etc/service/apache2 /etc/service/mysql /usr/share/phpinfo /usr/share/docs
ADD support/run_mysql.sh /etc/service/mysql/run
ADD support/run_apache2.sh /etc/service/apache2/run
ADD support/20_lampd.sh /etc/my_init.d/20_lampd.sh
ADD support/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD support/docs.php /usr/share/docs/index.php
ADD support/phpinfo.php /usr/share/phpinfo/index.php
ADD support/init.sql.tpl /usr/share/init.sql.tpl

# Configure Apache2.
RUN echo "ServerName $SERVER_NAME" >> /etc/apache2/apache2.conf && \
    sed -i "s#/var/www/#/project/app/#" /etc/apache2/apache2.conf && \
    chown -R www-data:www-data /var/www && \
    a2enmod rewrite

# Configure PHP.
RUN phpenmod intl && \
	PHP_CONFIG_FILE="/etc/php/$(php -v | head -n1 | cut -d' ' -f2 | cut -d'.' -f'1,2')/apache2/php.ini" && \
    sed -ri -e "s/^memory_limit.*/memory_limit = $PHP_MEMORY_LIMIT/" $PHP_CONFIG_FILE

# Configure MySQL.
RUN sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i "s/.*datadir.*/datadir = \/project\/mysql/" /etc/mysql/mysql.conf.d/mysqld.cnf && \
    rm -rf /var/lib/mysql && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld

# Clean up.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure image.
VOLUME [ "/project" ]
EXPOSE 80 3306
CMD ["/sbin/my_init"]