#!/bin/bash

## 01_apache2.2.21のインストール.md

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] START: ${BASH_SOURCE[0]}"

# 設定ファイルの読み込み
. ./config.sh

# 依存ライブラリのインストール
dnf -y install zlib zlib-devel openssl-devel libtool systemd-devel perl-core perl-FindBin perl-IPC-Cmd perl-Pod-Html

## apache ユーザーとグループの作成
add_user "${app_user_name}" "${app_user_pass}" "${app_user_group}"

## アプリケーションディレクトリの作成
mkdir -p "${app_dir}"
chown -R "${app_user_name}:${app_user_group}" "${app_dir}"

## rpmでOS標準のApacheが入っている場合、アンインストール
rpm -e httpd-devel-2.4.6-45.el7.centos.x86_64
rpm -e httpd-manual-2.4.6-45.el7.centos.noarch
rpm -e mod_ssl-2.4.6-45.el7.centos.x86_64
rpm -e mod_fcgid-2.3.9-4.el7.x86_64
rpm -e httpd-2.4.6-45.el7.centos.x86_64
rpm -e httpd-tools-2.4.6-45.el7.centos.x86_64

## apr インストール
cd ${usr_local_src_dir} || exit
wget https://dlcdn.apache.org//apr/${apr_ver}.tar.gz
tar -xvzf ${apr_ver}.tar.gz
cd ${apr_ver} || exit
./configure
make -j"$(nproc)"
make install

## Expat XML Parser インストール
cd ${usr_local_src_dir} || exit
wget https://github.com/libexpat/libexpat/releases/download/R_2_6_2/${expat_ver}.tar.gz
tar -xvzf ${expat_ver}.tar.gz
cd ${expat_ver} || exit
./configure
make -j"$(nproc)"
make install

## apr-util インストール
cd ${usr_local_src_dir} || exit
wget https://dlcdn.apache.org//apr/${apr_util_ver}.tar.gz
tar -xvzf ${apr_util_ver}.tar.gz
cd ${apr_util_ver} || exit
./configure --with-apr=/usr/local/apr \
--with-openssl=/usr/local/ssl
make -j"$(nproc)"
make install

## PCRE2 インストール
cd ${usr_local_src_dir} || exit
wget https://github.com/PCRE2Project/pcre2/releases/download/${pcre2_ver}/${pcre2_ver}.tar.gz
tar -xvzf ${pcre2_ver}.tar.gz
cd ${pcre2_ver} || exit
./configure
make -j"$(nproc)"
make install

## zlib インストール
cd ${usr_local_src_dir} || exit
wget https://zlib.net/${zlib_ver}.tar.gz
tar -xvzf ${zlib_ver}.tar.gz
cd ${zlib_ver} || exit
./configure
make
make install

## apache インストール
cd ${usr_local_src_dir} || exit
wget https://dlcdn.apache.org/httpd/${apache_ver}.tar.gz
tar -xvzf ${apache_ver}.tar.gz
cd ${apache_ver} || exit
# PCRE2のソースの場所を選択
./configure \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr \
--with-pcre=/usr/local/bin/pcre2-config \
--enable-mods-shared=reallyall \
--enable-ssl \
--with-ssl=/usr/local/ssl \
--enable-proxy \
--enable-headers \
--enable-rewrite=shared \
--enable-deflate \
--with-pcre=/usr/local \
--enable-systemd
make -j"$(nproc)"
make install

tmp=$(ls /usr/local/apache2 | wc -w)
if [ $tmp -lt 12 ]; then
  echo "[ERROR] [Line:$LINENO] Faild install"
  exit 1
fi
echo -e "[INFO] [Line:$LINENO] httpd version: \n$(/usr/local/apache2/bin/httpd -version)"

## mod_systemd.cを持ってくる
# あらかじめ「systemd-devel-219-62.el7.x86_64.rpm」がインストールされているかを確認しておきましょう。（これが入ってないと、sd-daemon.hがないといわれてコンパイルに失敗します）
cd ${usr_local_src_dir}/${apache_ver}/modules/arch/unix || exit
libtool \
--silent \
--mode=compile gcc -std=gnu99 -prefer-pic -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong \
--param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -D_LARGEFILE64_SOURCE  -DLINUX -D_REENTRANT -D_GNU_SOURCE \
-pthread -I/usr/local/apache2/include -I/usr/local/apr/include/apr-1 -c -o mod_systemd.lo mod_systemd.c && touch mod_systemd.slo
libtool \
--silent \
--mode=link gcc -std=gnu99 -Wl,-z,relro,-z,now,-L/usr/lib64 -o mod_systemd.la -rpath /usr/local/apache2/modules -module -avoid-version mod_systemd.lo
libtool \
--silent \
--mode=link gcc -std=gnu99 -Wl,-z,relro,-z,now,-L/usr/lib64 -o mod_systemd.la -rpath /usr/local/apache2/modules -module -avoid-version mod_systemd.lo -lsystemd
/usr/local/apache2/bin/apxs -i -a -n systemd mod_systemd.la


# httpd.service ユニット作成
cat << 'EOF' > /usr/lib/systemd/system/httpd.service
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
#EnvironmentFile=/usr/local/apache2/conf/httpd.conf
Environment=LD_LIBRARY_PATH=/usr/local/ssl/lib:/usr/local/lib:/usr/local/lib64:/usr/lib
ExecStart=/usr/local/apache2/bin/httpd -DFOREGROUND
#ExecReload=/usr/local/apache2/bin/httpd -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGTERM
PrivateTmp=true
Restart=on-failure
RestartSec=60
#StartLimitIntervalSec=3600
StartLimitInterval=3600
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF


## Enable mod_XXXX.so
sed -i '/^#.*mod_rewrite.so/s/^#//' /usr/local/apache2/conf/httpd.conf
sed -i '/^#.*mod_deflate.so/s/^#//' /usr/local/apache2/conf/httpd.conf
sed -i '/^#.*mod_proxy.so/s/^#//' /usr/local/apache2/conf/httpd.conf

## apache user
sed -i -e "s/User daemon/User ${app_user_name}/g" /usr/local/apache2/conf/httpd.conf
sed -i -e "s/Group daemon/Group ${app_user_group}/g" /usr/local/apache2/conf/httpd.conf

## カスタム設定
tmp=$(grep 'customize.conf' /usr/local/apache2/conf/httpd.conf)
if [ -z $tmp ]; then

cat << 'EOF' >> /usr/local/apache2/conf/httpd.conf

# Customize config
Include conf/extra/customize.conf
EOF

fi

tmp=$(find /usr/local/apache2/conf/extra -name "*customize.conf*")
if [ -z $tmp ]; then
touch /usr/local/apache2/conf/extra/customize.conf

# Security
cat << 'EOF' > /usr/local/apache2/conf/extra/customize.conf
# Security
ServerTokens Prod
ServerSignature Off
TraceEnable off

# deflate  @todo Compress to Brotli
<IfModule deflate_module>
    # @see 
    # https://httpd.apache.org/docs/2.4/mod/mod_deflate.html
    # http://hs-www.hyogo-dai.ac.jp/~kawano/?Install%20Log%2FCentOS5%2Fmod_deflate
    # http://www.gidnetwork.com/tools/gzip-test.php

    # CompressionLevel 1~9
    DeflateCompressionLevel 1

    # Insert filter
    SetOutputFilter DEFLATE

    # Netscape 4.x has some problems...
    BrowserMatch ^Mozilla/4 gzip-only-text/html

    # Netscape 4.06-4.08 have some more problems
    BrowserMatch ^Mozilla/4\.0[678] no-gzip

    # MSIE masquerades as Netscape, but it is fine
    # BrowserMatch \bMSIE !no-gzip !gzip-only-text/html

    # Don't compress images
    SetEnvIfNoCase Request_URI \
    \.(?:gif|jpe?g|png)$ no-gzip dont-vary

    # Make sure proxies don't deliver the wrong content
    Header append Vary User-Agent env=!dont-vary

    # Log
    DeflateFilterNote Input instream
    DeflateFilterNote Output outstream
    DeflateFilterNote Ratio ratio
    LogFormat '"%r" %{outstream}n/%{instream}n (%{ratio}n%%) %{User-agent}i' deflate
    CustomLog logs/deflate_log deflate
</IfModule>

# mpm_event_module
<IfModule mpm_event_module>
    StartServers             3
    MinSpareThreads          20
    MaxSpareThreads          50
    ThreadLimit              50
    ThreadsPerChild          15
    MaxRequestWorkers        60
    MaxConnectionsPerChild   5000
</IfModule>
EOF
fi


# ログディレクトリ 作成
mkdir -p "${apache_log_dir}" && chmod 777 "${apache_log_dir}"

# httpdをデフォルトからインストールしたhttpdに変更
systemctl stop httpd
systemctl disable httpd
echo "export PATH=/usr/local/apache2/bin:${PATH}" >> ~/.bash_profile
source "${HOME}/.bash_profile"
ln -sf /usr/local/apache2/bin/httpd /usr/sbin/httpd

systemctl daemon-reload
# 起動
systemctl start httpd
# 自動起動ON
enable_service "httpd"
echo -e "[INFO] [Line:$LINENO] httpd status: \n$(systemctl status httpd)"
echo -e "[INFO] [Line:$LINENO] which httpd: \n$(which httpd)"


echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] END: ${BASH_SOURCE[0]}"


# 補足##########################################
# 
# systemctl restart httpd
# systemctl reload httpd
# systemctl stop httpd
# 
# ### 参考
# [Apache2.4をインストールする(ソースからコンパイル) for RockeyLinux 9.x / Ubuntu 22.04.x(systemd対応)](https://qiita.com/shadowhat/items/163ee5fdd56c51100e9e)
# [apxsで apacheにモジュールを追加する](https://kazmax.zpp.jp/apache/apache3.html)
# [Install Apache Module mod_systemd](https://unix.stackexchange.com/questions/262051/install-apache-module-mod-systemd)
# [Apacheのevent MPMのパフォーマンスチューニング方法](https://qiita.com/rryu/items/5e02ea60e36d7fd956b8)
################################################
