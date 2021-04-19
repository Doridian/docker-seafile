#!/bin/bash
set -eu

export DB_HOST=127.0.0.1

# Initialize DB if needed
if [ ! -d /var/lib/mysql/mysql ]
then
    sv stop mysqld
    chown -R mysql:mysql /var/lib/mysql
    chmod 700 /var/lib/mysql
    mysql_install_db --user=mysql --auth-root-authentication-method=normal --datadir=/var/lib/mysql
    sv start mysqld
fi

timeout 60 /scripts/wait_mysql.sh

# Initialize root PW if needed
if [ ! -f /var/lib/mysql/dotmy.cnf ]
then
    if [ -z "${DB_ROOT_PASSWD:-}" ]
    then
        echo 'No DB_ROOT_PASSWD given, generating one randomly...'
        export DB_ROOT_PASSWD="$(dd status=none if=/dev/urandom of=/dev/stdout bs=48 count=1 | base64)"
    fi
    mysql mysql -B -e "UPDATE user SET password = PASSWORD('$DB_ROOT_PASSWD') WHERE User = 'root';"
    echo '[mysql]' > /var/lib/mysql/dotmy.cnf
    chmod 600 /var/lib/mysql/dotmy.cnf
    echo "password=$DB_ROOT_PASSWD" >> /var/lib/mysql/dotmy.cnf
    mysqladmin flush-privileges
fi

export DB_ROOT_PASSWD="$(grep -Po '(?<=password=).+' /root/.my.cnf)"

echo 'Giving control to /scripts/start.py'
exec /scripts/start.py
