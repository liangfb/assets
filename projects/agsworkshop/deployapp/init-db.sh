#!/bin/bash
echo 'Config database...'
echo 'DBHost:' $1
echo 'User:' $2
echo 'Password:' $3
echo 'MagentoUrl:' $4

#mysql -h$1 -u$2 -p$3 -e "drop database magento;"
mysql -h$1 -u$2 -p$3 < magento.sql
mysql -h$1 -u$2 -p$3 -e "update magento.core_config_data set value='http://$4/' where path='web/unsecure/base_url';update magento.core_config_data set value='https://$4/' where path='web/secure/base_url';"