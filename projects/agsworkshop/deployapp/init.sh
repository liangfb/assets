#!/bin/bash
echo 'Config application...'
echo 'DBHost:' $1
echo 'User:' $2
echo 'Password:' $3

sed -i "s/%host%/$1/g" /var/www/html/app/etc/env.php
sed -i "s/%username%/$2/g" /var/www/html/app/etc/env.php
sed -i "s/%password%/$3/g" /var/www/html/app/etc/env.php

/var/www/html/bin/magento cache:clean
/var/www/html/bin/magento setup:di:compile
/var/www/html/bin/magento setup:static-content:Deploy -f