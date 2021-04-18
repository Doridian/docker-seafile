#!/bin/bash
set -eu

export DB_HOST=localhost

if [ ! -d /var/lib/mysql/seafile_db ]
then
    service mysql stop
    rm -rf /var/lib/mysql/*
    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --auth-root-authentication-method=normal --datadir=/var/lib/mysql
fi

service mysql start

if [ ! -f /var/lib/mysql/dotmy.cnf ]
then
    mysql mysql -B -e "UPDATE user SET password = PASSWORD('$DB_ROOT_PASSWD') WHERE User = 'root';"
    echo '[mysql]' > /var/lib/mysql/dotmy.cnf
    echo "password=$DB_ROOT_PASSWD" >> /var/lib/mysql/dotmy.cnf
    mysqladmin flush-privileges
fi

echo 'Giving control to /scripts/start.py'

exec /scripts/start.py
