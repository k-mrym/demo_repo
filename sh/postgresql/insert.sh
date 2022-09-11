#!/bin/bash

declare -r COTAINER_NAME=XXXX_postgres-1
declare -r DATABASE=XXXXdb
declare -r USER=XXXX
declare -r PASS=XXXX
# declare QUERY="INSERT INTO public.dtb_payment (id, creator_id, payment_method, charge, rule_max, sort_no, fixed, payment_image, rule_min, method_class, visible, create_date, update_date, discriminator_type) VALUES (100, NULL, 'test', 0.00, NULL, 10, true, NULL, 0.00, 'Eccube\Service\Payment\Method\Cash', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'payment')"

# syntax error になる
# docker exec ${COTAINER_NAME} psql -U ${USER} -w ${PASS} -d ${DATABASE} -c ${QUERY};


docker exec ${COTAINER_NAME} psql -U ${USER} -w ${PASS} -d ${DATABASE} -c "INSERT INTO dtb_payment (id, creator_id, payment_method, charge, rule_max, sort_no, fixed, payment_image, rule_min, method_class, visible, create_date, update_date, discriminator_type) VALUES (100, NULL, 'test', 0.00, NULL, 10, true, NULL, 0.00, 'Eccube\Service\Payment\Method\Cash', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'payment')";
