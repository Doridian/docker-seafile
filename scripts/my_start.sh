#!/bin/bash
set -eu

export DB_HOST=127.0.0.1
export DB_MY_CONF='/var/lib/mysql/dotmy.cnf'
export DB_MY_CONF_ARG="--defaults-file=$DB_MY_CONF"

if [ ! -f "$DB_MY_CONF" ]
then
    echo '[client]' > "$DB_MY_CONF"
    chmod 600 "$DB_MY_CONF"
fi

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
if ! grep -qF 'password=' "$DB_MY_CONF"
then
    if [ -z "${DB_ROOT_PASSWD:-}" ]
    then
        echo 'No DB_ROOT_PASSWD given, generating one randomly...'
        export DB_ROOT_PASSWD="$(dd status=none if=/dev/urandom of=/dev/stdout bs=48 count=1 | base64)"
    fi
    mysql "$DB_MY_CONF_ARG" mysql -B -e "UPDATE user SET password = PASSWORD('$DB_ROOT_PASSWD') WHERE User = 'root';"
    mysqladmin flush-privileges || true
    echo "password=$DB_ROOT_PASSWD" >> "$DB_MY_CONF"
    mysqladmin "$DB_MY_CONF_ARG" flush-privileges
fi

export DB_ROOT_PASSWD="$(grep -Po '(?<=password=).+' /root/.my.cnf)"

mkdir -p /shared/seafile/logs /shared/seafile/seahub-data/custom
chown seafile:seafile /shared/seafile/logs /shared/seafile/seahub-data /shared/seafile/seahub-data/custom

# Initialize DDNS cron if needed
if [ ! -f /root/ddns_configured ]
then
    echo >> /etc/crontab
    if [ ! -z "${DDNS_URL_IPV4:-}" ]
    then
        echo "*/5 * * * *  nobody /usr/bin/curl -4 '$DDNS_URL_IPV4'" >> /etc/crontab
    fi
    if [ ! -z "${DDNS_URL_IPV6:-}" ]
    then
        echo "*/5 * * * *  nobody /usr/bin/curl -6 '$DDNS_URL_IPV6'" >> /etc/crontab
    fi
    touch /root/ddns_configured
fi

if [ ! -z "${DDNS_URL_IPV4:-}" ]
then
    /usr/bin/curl -4 "$DDNS_URL_IPV4" || true
fi
if [ ! -z "${DDNS_URL_IPV6:-}" ]
then
    /usr/bin/curl -6 "$DDNS_URL_IPV6" || true
fi

echo 'Giving control to /scripts/start.py'
exec /scripts/start.py
