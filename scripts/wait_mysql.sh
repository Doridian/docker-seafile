#!/bin/bash
set -eu

echo -n 'Waiting for MySQL...'
until mysql mysql -B -e 'SELECT 1' &> /dev/null
do
    echo -n '.'
    sleep 1
done
echo ' OK'