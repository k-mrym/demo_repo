#!/bin/bash

tmp_dir=/home/tmp
usr_local_src_dir=/usr/local/src

apache_ver="httpd-2.4.62"
apr_ver="apr-1.7.5"
expat_ver="expat-2.6.2"
apr_util_ver="apr-util-1.6.3"
pcre2_ver="pcre2-10.43"
zlib_ver="zlib-1.3.1"
apache_service=$systemd_dir/httpd.service
apache_dir=/usr/local/apache2
apache_log_dir=/usr/local/apache2/logs
apache_conf_dir=${apache_dir}/conf
apache_conf=${apache_conf_dir}/httpd.conf
