#!/bin/bash

tmp_dir=/home/tmp
usr_local_src_dir=/usr/local/src

apache_conf_dir=${apache_dir}/conf
apache_conf=${apache_conf_dir}/httpd.conf

php_ver="8.1.29"
php_install_dir=/usr/local/php
php_ini=$php_install_dir/etc/php.ini
mime_types_conf=/usr/local/apache2/conf/mime.types
php_opcache_so=/usr/local/lib/php-8.1.29/lib/php/extensions/no-debug-zts-20210902/opcache.so
php_opcache_so=/usr/local/lib/php/extensions/opcache.so
php_log_dir=$php_install_dir/var/log
php_log=$php_log_dir/php.log
php_curl_so=

composer_bin=/usr/local/bin/composer
