FROM seafileltd/seafile-mc:latest

RUN apt-get update && apt-get install -y wget mariadb-server memcached && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i 's~memcached:11211~127.0.0.1:11211~g' /scripts/bootstrap.py
RUN sed -i 's~%.%.%.%~localhost~g' /scripts/bootstrap.py

RUN ln -s /var/lib/mysql/dotmy.cnf /root/.my.cnf
VOLUME "/var/lib/mysql"

COPY my_start.sh /sbin/my_start.sh
RUN chmod 755 /sbin/my_start.sh

CMD ["/sbin/my_init", "--", "/sbin/my_start.sh"]
