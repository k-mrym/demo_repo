#!/bin/bash

TARGET_DIR='/var/www/sdbghdfhasgazsnh.com/tmp/test_upload_files'
ADDRESS_NUM=10
FILE_NUM=10
DOMAIN=test_domain.com

if [ ! -d $TARGET_DIR ]; then
  echo "mkdir $TARGET_DIR"
  mkdir -p $TARGET_DIR
fi

for i in $(awk "BEGIN{for(i=1; i<=$FILE_NUM; ++i) print i}"); do
  FILE="${TARGET_DIR}/test${i}.csv"
  echo "$FILE"
  touch "$FILE"
  STR=$(openssl rand -base64 12 | fold -w 10 | head -1)
  for ii in $(awk "BEGIN{for(i=1; ii<=$ADDRESS_NUM; ++ii) print ii}"); do
    echo "${ii}_${STR}@${DOMAIN}" >> "$FILE"
  done
done
