#!/bin/bash

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] START: ${BASH_SOURCE[0]}"

# 設定ファイルの読み込み
. ./config.sh

cd "${tmp_dir}" || exit
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
mv ./composer.phar "$composer_bin"
# composer --version  # rootユーザー以外で実行
composer_version=$(sudo -u $admin_user_name "$composer_bin" --version | grep "version")
echo "[INFO] [Line:$LINENO] composer_version: $composer_version"


echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] END: ${BASH_SOURCE[0]}"
