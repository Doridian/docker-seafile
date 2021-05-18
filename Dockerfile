FROM seafileltd/seafile-mc:latest

RUN apt-get update && apt-get install -y wget mariadb-server memcached sudo curl && apt-get clean && rm -rf /var/lib/apt/lists/*

# Prepare Seafile perms to not have to run as root
RUN groupadd -g 10001 seafile && useradd -u 10001 -g 10001 seafile
RUN chown -R seafile:seafile /opt/seafile

# Prepare MySQL config
RUN rm -rf /var/lib/mysql/*
RUN ln -s /var/lib/mysql/dotmy.cnf /root/.my.cnf
VOLUME "/var/lib/mysql"

# Add mysql and memcached services to runit
RUN mkdir -p /etc/service/mysqld /etc/service/mysqld/control /etc/service/memcached
COPY services/mysqld.sh /etc/service/mysqld/run
COPY services/mysqld_stop.sh /etc/service/mysqld/control/t
COPY services/memcached.sh /etc/service/memcached/run
RUN chmod 755 /etc/service/*/run /etc/service/*/control/*

# Patch scripts that ship with Seafile
COPY scripts.patch /scripts.patch
RUN patch -p1 -i /scripts.patch -d /scripts && rm -f /scripts.patch

# Add custom start script
COPY scripts/ /scripts/
RUN chmod 755 /scripts/*.sh

CMD ["/sbin/my_init", "--", "/scripts/my_start.sh"]
