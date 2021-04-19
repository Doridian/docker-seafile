FROM seafileltd/seafile-mc:latest

RUN apt-get update && apt-get install -y wget mariadb-server memcached && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i 's~memcached:11211~127.0.0.1:11211~g' /scripts/bootstrap.py
RUN sed -i 's~%.%.%.%~127.0.0.1~g' /scripts/bootstrap.py

RUN rm -rf /var/lib/mysql/*

RUN ln -s /var/lib/mysql/dotmy.cnf /root/.my.cnf
VOLUME "/var/lib/mysql"

RUN mkdir -p /etc/service/mysqld /etc/service/memcached
COPY services/mysqld.sh /etc/service/mysqld/run
COPY services/memcached.sh /etc/service/memcached/run
RUN chmod 755 /etc/service/*/run

COPY scripts/ /scripts/
RUN chmod 755 /scripts/*.sh

CMD ["/sbin/my_init", "--", "/scripts/my_start.sh"]
