#!/bin/bash
set -eu

echo -n 'Waiting for MySQL...'
until mysql "$DB_MY_CONF_ARG" mysql -B -e 'SELECT 1' &> /dev/null
do
    echo -n '.'
    sleep 1
done
echo ' OK'
