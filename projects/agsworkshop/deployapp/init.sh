#!/bin/bash
echo 'DBHost:' $1
echo 'User:' $2
echo 'Password:' $3
echo 'MagentoUrl:' $4

sed -i "s/%host%/$1/g" /var/www/html/app/etc/env.php
sed -i "s/%username%/$2/g" /var/www/html/app/etc/env.php
sed -i "s/%password%/$3/g" /var/www/html/app/etc/env.php

mysql -h$1 -u$2 -p$3 < magento.sql

update magento.core_config_data set web/unsecure/base_url='http://$4/', web/secure/base_url='http://$4/', web/unsecure/base_url='http://$4/' where path like '%base_url';