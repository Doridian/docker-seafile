#!/bin/bash
set -eu

cd /opt/seafile/seafile-server-latest

pkill -STOP -fe /scripts/start.py

./seafile.sh stop
sleep 1
./seahub.sh stop
sleep 1

./seaf-gc.sh "$@"

pkill -CONT -fe /scripts/start.py