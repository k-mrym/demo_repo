#!/bin/bash

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] START: ${BASH_SOURCE[0]}"

# 設定ファイルの読み込み
. ./config.sh

# 依存ライブラリのインストール
dnf install -y \
libxml2 libxml2-devel \
libjpeg libjpeg-devel \
libpng libpng-devel \
libmcrypt libmcrypt-devel \
curl curl-devel \
openssl openssl-devel \
freetype freetype-devel \
zlib zlib-devel \
bzip2 bzip2-devel \
gmp gmp-devel \
oniguruma oniguruma-devel \
aspell aspell-devel \
re2c \
libxslt libxslt-devel \
libcurl libcurl-devel \
krb5-devel \
sqlite sqlite-devel

# php インストール
cd "${usr_local_src_dir}" || exit
wget http://jp2.php.net/get/php-${php_ver}.tar.gz/from/this/mirror -O php-${php_ver}.tar.gz && \
tar -zxvf php-${php_ver}.tar.gz
cd php-${php_ver} || exit
./configure \
--prefix=/usr/local/lib/php-8.1.29 \
--with-config-file-path=/usr/local/lib/php-8.1.29/etc \
--with-apxs2=/usr/local/apache2/bin/apxs \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-pdo-mysql=/usr/local/mysql \
--with-openssl=/usr/local/ssl \
--with-zlib \
--with-curl \
--enable-mbstring \
--enable-intl \
--enable-soap \
--enable-bcmath \
--with-gettext \
--with-pear \
--enable-sockets \
--enable-exif \
--enable-shmop \
--enable-sysvsem \
--enable-sysvshm \
--enable-pcntl \
--with-kerberos \
--with-libdir=lib64
make -j"$(nproc)"
make install

# シンボリックリンク
ln -sf /usr/local/lib/php-8.1.29 /usr/local/php
echo -e "[INFO] [Line:$LINENO] php --version: \n$(/usr/local/php/bin/php --version)"


### 設定ファイル

## mime.types 
# php拡張子（.php,phps）を有効
tmp=$(grep 'x-httpd-php' $mime_types_conf)
if [ -z "$tmp" ]; then
  echo 'application/x-httpd-php php' >> $mime_types_conf
  echo 'application/x-httpd-source phps' >> $mime_types_conf
fi

## httpd.conf
# DirectoryIndex index.html の後ろに index.php 追加
tmp=$(grep 'index.php' $apache_conf)
if [ -z "$tmp" ]; then
  sed -i 's/DirectoryIndex index\.html/& index.php/' "${apache_conf}"
fi
echo -e "[INFO] [Line:$LINENO] DirectoryIndex: \n$(grep "DirectoryIndex" "${apache_conf}")"
# php_module
tmp=$(grep 'LoadModule php_module' $apache_conf)
if [ -z "$tmp" ]; then
  echo 'LoadModule php_module         modules/libphp.so' >> "${apache_conf}"
fi
echo -e "[INFO] [Line:$LINENO] LoadModule php_module: \n$(grep "LoadModule php_module" "${apache_conf}")"
# php-script
tmp=$(grep 'AddHandler php-script' $apache_conf)
if [ -z "$tmp" ]; then
  echo 'AddHandler php-script .php' >> "${apache_conf}"
fi
echo -e "[INFO] [Line:$LINENO] AddHandler php-script: \n$(grep "AddHandler php-script" "${apache_conf}")"

## php.ini
php_ini_org=""
if [ $env = 'env' ]; then
  php_ini_org=/usr/local/src/php-8.1.29/php.ini-development
elif [ $env = 'prod' ]; then
  php_ini_org=/usr/local/src/php-8.1.29/php.ini-production
fi
\cp -af $php_ini_org /usr/local/php/etc/php.ini
chmod 644 /usr/local/php/etc/php.ini

# ショートタグ <? ?>
sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /usr/local/php/etc/php.ini

# error_log
tmp=$(grep "^error_log" /usr/local/php/etc/php.ini)
if [ -z "$tmp" ]; then
cat << 'EOF' >> /usr/local/php/etc/php.ini

error_log = /usr/local/php/var/log/php.log
EOF
mkdir -p ${php_log_dir} && touch ${php_log} && chmod 666 ${php_log}
fi

# error_reporting
sed -i '/^error_reporting =/c\error_reporting = E_ALL & ~E_NOTICE & ~E_DEPRECATED' /usr/local/php/etc/php.ini

# opecache
tmp=$(grep 'opcache.so' /usr/local/php/etc/php.ini)
if [ -z "$tmp" ]; then
cat << 'EOF' >> /usr/local/php/etc/php.ini

[opcache]
zend_extension = /usr/local/lib/php-8.1.29/lib/php/extensions/no-debug-zts-20210902/opcache.so
opcache.enable_cli = 1
opcache.enable = 1
opcache.memory_consumption = 64
opcache.interned_strings_buffer = 4
opcache.max_accelerated_files = 4000
opcache.revalidate_freq = 2
opcache.fast_shutdown = 1
EOF
fi

# apache再起動
systemctl restart httpd.service
$wait

# 確認
echo "<?php phpinfo(); ?>" > /usr/local/apache2/htdocs/info.php
php_info=$(curl "http://${ip_adrr}/info.php")
echo -e "[INFO] [Line:$LINENO] php_info: \n$php_info"

# インストールしたphpでphpコマンドのシンボリックリンク作成
ln -sf /usr/local/php/bin/php /usr/bin
which_php=$(which php)
echo -e "[INFO] [Line:$LINENO] which_php: $which_php"


echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] END: ${BASH_SOURCE[0]}"
