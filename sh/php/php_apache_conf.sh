#!/bin/bash

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] START: ${BASH_SOURCE[0]}"

# 設定ファイルの読み込み
. ./config.sh

# リロード
systemctl restart httpd.service

echo "[INFO] php -m: $(php -m)"

# opcache.so
tmp=$(php -m | grep "Zend OPcache")
if [ -z "$tmp" ]; then
  echo "[ERROR] [Line:$LINENO] Faild include opcache"
  exit 1
fi

# curl
tmp=$(php -m | grep curl)
if [ -z "$tmp" ]; then
  echo "[ERROR] [Line:$LINENO] Faild include curl"
  exit 1
fi

# httpdインストール確認
tmp=$(systemctl list-unit-files | grep httpd)
$wait
if [ -z "$tmp" ]; then
  echo "[ERROR] [Line:$LINENO] Empty: systemctl list-unit-files | grep httpd"
  exit 1
fi
echo "[INFO] [Line:$LINENO] php_httpd: $tmp"

# ブラウザ表示確認
tmp=$(curl "http://$(curl inet-ip.info)")
$wait
if [ -z "$tmp" ]; then
  echo "[ERROR] [Line:$LINENO] Empty: curl \"http://$(curl inet-ip.info)\""
  exit 1
fi
echo "[INFO] [Line:$LINENO] browser_display: $tmp"

# SSLモジュールパッケージ名の確認
echo "[INFO] [Line:$LINENO] mod_ssl: $(dnf search mod_ssl)"
# mod_ssl.x86_64 : SSL/TLS module for the Apache HTTP Server
$wait


echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] END: ${BASH_SOURCE[0]}"
