<?php
header('Content-Type: text/plain; charset=UTF-8');
echo "LAMPD\n\n";
echo "OS Version:\t\t", exec('lsb_release -ds'), "\n";
echo "Apache Version:\t\t", apache_get_version(), "\n";
echo "PHP Version:\t\t", phpversion(), "\n";
echo "MySQL Version:\t\t", exec('mysqld --version'), "\n";
echo "phpMyAdmin Version:\t", exec('dpkg -s phpmyadmin | grep Version | cut -d" " -f2'), "\n";
echo "Composer Version:\t", exec('COMPOSER_HOME=/var/www composer --version --no-ansi'), "\n";
echo "PHP Time:\t\t", date(DATE_ATOM), "\n";
?>
