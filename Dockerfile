FROM seafileltd/seafile-mc:latest

RUN apt-get update && apt-get install -y wget mariadb-server memcached sudo && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1001 seafile && useradd -u 1001 -g 1001 seafile
RUN chown -R seafile:seafile /opt/seafile

RUN rm -rf /var/lib/mysql/*
RUN ln -s /var/lib/mysql/dotmy.cnf /root/.my.cnf
VOLUME "/var/lib/mysql"

RUN mkdir -p /etc/service/mysqld /etc/service/mysqld/control /etc/service/memcached
COPY services/mysqld.sh /etc/service/mysqld/run
COPY services/mysqld_stop.sh /etc/service/mysqld/control/t
COPY services/memcached.sh /etc/service/memcached/run
RUN chmod 755 /etc/service/*/run /etc/service/*/control/*

RUN sed -i 's~memcached:11211~127.0.0.1:11211~g' /scripts/bootstrap.py
RUN sed -i 's~%.%.%.%~127.0.0.1~g' /scripts/bootstrap.py
RUN sed -i "s~call('{} auto -n seafile'~call('sudo -E -H -u seafile {} auto -n seafile'~g" /scripts/bootstrap.py
RUN sed -i "s~call('{} start'~call('sudo -E -H -u seafile {} start'~g" /scripts/start.py

COPY scripts/ /scripts/
RUN chmod 755 /scripts/*.sh

CMD ["/sbin/my_init", "--", "/scripts/my_start.sh"]
