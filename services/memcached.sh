#!/bin/sh
exec 2>&1
exec /usr/bin/memcached -m 64 -p 11211 -u memcache -l 127.0.0.1
