FROM phusion/baseimage:latest
MAINTAINER Daniel Graziotin <daniel@ineed.coffee>

# based on dgraziotin/lamp, which is based on
# tutumcloud/tutum-docker-lamp
# MAINTAINER Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

# Tweaks to give MySQL write permissions to the app
RUN useradd -r mysql -u ${BOOT2DOCKER_ID} && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install apt-utils && \
  apt-get -y install supervisor wget git mysql-server pwgen zip unzip

# Add image configuration and scripts
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD create_mysql_users.sh /create_mysql_users.sh
RUN chmod 755 /*.sh

ENV MYSQL_PASS:-$(pwgen -s 12 1)

# Add volumes for the app and MySql
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 3306
CMD ["/run.sh"]