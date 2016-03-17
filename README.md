#osx-docker-mysql, a.k.a dgraziotin/mysql

    Out-of-the-box MySQL Docker image that *just works* on Mac OS X.
    Including write support for mounted volumes (MySQL).
    No matter if using the official boot2docker or having Vagrant in the stack, as well.

osx-docker-mysql, which is known as 
[dgraziotin/mysql](https://registry.hub.docker.com/u/dgraziotin/mysql/) 
in the Docker Hub, is a reduced fork of 
[dgraziotin/osx-docker-lamp](https://github.com/dgraziotin/osx-docker-lamp), 
which is an "Out-of-the-box LAMP image (PHP+MySQL) for Docker". 

Some info about osx-docker-mysql:

- It is based on [phusion/baseimage:latest](http://phusion.github.io/baseimage-docker/)
  instead of ubuntu:trusty.
- It works flawlessy regardless of using boot2docker standalone or with Vagrant. You will need to set three environment variables, though.
- It fixes OS X related [write permission errors for MySQL](https://github.com/boot2docker/boot2docker/issues/581)
- It lets you mount OS X folders *with write support* as volumes for
  - The database
- If `CREATE_MYSQL_BASIC_USER_AND_DB="true"`, it creates a default database and user with permissions to that database
- It is documented for less advanced users (like me)

##Usage

    If using Vagrant, please see the extra steps in the next subsection.

If you need to create a custom image `youruser/mysql`, 
execute the following command from the `osx-docker-mysql` source folder:

    docker build -t youruser/mysql .

If you wish, you can push your new image to the registry:

    docker push youruser/mysql

Otherwise, you are free to use dgraziotin/mysql as it is provided. Remember first
to pull it from the Docker Hub:

    docker pull dgraziotin/mysql

###Vagrant

If, for any reason, you would rather use Vagrant (I suggest using [AntonioMeireles/boot2docker-vagrant-box](https://github.com/AntonioMeireles/boot2docker-vagrant-box)), you need to add the following three variables when running your box:

-`VAGRANT_OSX_MODE="true"` for enabling Vagrant-compatibility
-`DOCKER_USER_ID=$(id -u)` for letting Vagrant use your host user ID for mounted folders
-`DOCKER_USER_GID=$(id -g)` for letting Vagrant use your host user GID for mounted folders

See the Environment variables section for more options.

###Running your MySQL docker image

If you start the image without supplying your code, e.g.,

    docker run -t -i -p 3306:3306 --name db dgraziotin/mysql

At [boot2docker ip] you should be able to connect to MySQL.

###Loading your custom MySQL files

If you wish to mount a MySQL folder locally, so that MySQL files are saved on your
OS X machine, run the following instead:

    docker run -i -t -p "3306:3306" -v ${PWD}/mysql:/var/lib/mysql --name db dgraziotin/mysql

The MySQL database will thus become persistent at each subsequent run of your image.

##Environment description

###The /mysql folder

MySQL is configured to serve the files from the `/mysql` folder, which is a symbolic
link to `/var/lib/mysql`. In osx-docker-mysql, the MySQL user `mysql` 
has full write permissions to the `mysql` folder.

###MySQL

MySQL runs as user `mysql` and group `staff`.

####The three MySQL users

The bundled MySQL server has two users, that are `root` and `admin`, and an optional
third user `user`.

The `root` account comes with an empty password, and it is for local connections
(e.g., using some code). The `root` user cannot remotely access the database 
(and the container).

However, the first time that you run your container, a new user `admin` 
with all root privileges  will be created in MySQL with a random password. 

To get the password, check the logs of the container by running:

    docker logs [name or id, e.g., mywebsite]

You will see an output like the following:

    ========================================================================
    You can now connect to this MySQL Server using:

        mysql -uadmin -p47nnf4FweaKu -h<host> -P<port>

    Please remember to change the above password as soon as possible!
    MySQL user 'root' has no password but only allows local connections
    ========================================================================

In this case, `47nnf4FweaKu` is the password allocated to the `admin` user.

Finally, an optional a user called `user` with password `password` can be created for your convenience either when:
 - The environment variable `CREATE_MYSQL_BASIC_USER_AND_DB` is true; or
 - Any of the `MYSQL_USER_*` variable (explained below) is true
The user is called `user` and has as password `password`.

The `user` user has full privileges on a database called `db`, which is also created
for your convenience. As with the `admin` user, the user `user` can access
the MySQL server from any host (`%`).
The user name, password, and database name can be changed using
the the `MYSQL_USER_*` variables, explained below.

##Environment variables

- `MYSQL_ADMIN_PASS="mypass"` will use your given MySQL password for the `admin`
user instead of the random one.
- `CREATE_MYSQL_BASIC_USER_AND_DB="true"` will create the user `user` with db `db` and password `password`. Not needed if using one of the following three `MYSQL_USER_*` variables
- `MYSQL_USER_NAME="daniel"` will use your given MySQL username instead of `user`
- `MYSQL_USER_DB="supercooldb"` will use your given database name instead of `db`
- `MYSQL_USER_PASS="supersecretpassword"` will use your given password  instead of `password`
-`VAGRANT_OSX_MODE="true"` for enabling Vagrant-compatibility
-`DOCKER_USER_ID=$(id -u)` for letting Vagrant use your host user ID for mounted folders
-`DOCKER_USER_GID=$(id -g)` for letting Vagrant use your host user GID for mounted folders

Set these variables using the `-e` flag when invoking the `docker` client.

    docker run -i -t -p "3306:3306" -e MYSQL_ADMIN_PASS="mypass" --name yourdb dgraziotin/mysql

Please note that the MySQL variables will not work if an existing MySQL volume is supplied.
