#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

# Tweaks to give Apache/PHP write permissions to the app
chown -R mysql:staff /var/lib/mysql
chmod -R 770 /var/lib/mysql

if [ -n "$VAGRANT_OSX_MODE" ];then
    usermod -u $DOCKER_USER_ID mysql
    groupmod -g $(($DOCKER_USER_GID + 10000)) $(getent group $DOCKER_USER_GID | cut -d: -f1)
    groupmod -g ${DOCKER_USER_GID} staff
fi

# Tweaks to give MySQL write permissions to the app
chmod -R 770 /var/lib/mysql
chown -R mysql:staff /var/lib/mysql

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/user.*/user = mysql/" /etc/mysql/mysql.conf.d/mysqld.cnf

mkdir -p /var/run/mysqld
chown -R mysql:staff /var/run/mysqld
chmod -R 770 /var/run/mysqld

if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysqld --initialize-insecure > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_users.sh
else
    echo "=> Using an existing volume of MySQL"
fi

exec supervisord -n
