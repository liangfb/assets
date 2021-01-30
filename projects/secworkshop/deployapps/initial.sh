#!/bin/bash
echo 'Host:' $1
echo 'User:' $2
echo 'Password:' $3
echo 'Website:' $4

sed -i "s/%host%/$1/g" /var/www/html/wp-config.php
sed -i "s/%username%/$2/g" /var/www/html/wp-config.php
sed -i "s/%password%/$3/g" /var/www/html/wp-config.php

mysql -h$1 -u$2 -p$3 < wordpressdb.sql

mysql -h$1 -u$2 -p$3 -e "use wordpressdb; update wp_options set option_value='http://$4' where option_name='siteurl' or option_name='home'; update wp_posts set post_content = replace(post_content, '54.92.58.70', '$4');"