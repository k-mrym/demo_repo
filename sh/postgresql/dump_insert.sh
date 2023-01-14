#!/bin/bash

declare -r COTAINER_NAME=XXXX_postgres-1
declare -r DATABASE=XXXXdb
declare -r USER=XXXXuser
declare -r TABLE_NAME=dtb_XXXX

pg_dump --username=${USER} --table ${TABLE_NAME} --data-only --column-inserts ${DATABASE} > ${TABLE_NAME}.sql

# docker exec ${COTAINER_NAME} pg_dump --username=${USER} --table ${TABLE_NAME} --data-only --column-inserts ${DATABASE} > ${TABLE_NAME}.sql

cat ${TABLE_NAME}.sql
rm ${TABLE_NAME}.sql
