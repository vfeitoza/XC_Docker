#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --skip-grant-tables &
sleep 5

mysql -e "FLUSH PRIVILEGES;"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '';"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin shutdown
sleep 2

exec mysqld_safe
