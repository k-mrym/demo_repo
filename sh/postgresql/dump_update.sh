#!/bin/bash

declare -r COTAINER_NAME=XXXX_postgres-1
declare -r TABLE_NAME=dtb_XXXX

# pg_dump --username=dbuser --table ${TABLE_NAME} --data-only --column-updates eccubedb > ${TABLE_NAME}.sql

docker exec ${COTAINER_NAME} pg_dump --username=dbuser --table ${TABLE_NAME} --data-only --column-updates eccubedb > ${TABLE_NAME}.sql

cat ${TABLE_NAME}.sql
rm ${TABLE_NAME}.sql
