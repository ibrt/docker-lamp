# ibrt/lamp
[![Docker Build Status](https://img.shields.io/docker/build/ibrt/lamp.svg)](https://hub.docker.com/r/ibrt/lamp/builds)
[![Docker Image](https://images.microbadger.com/badges/image/ibrt/lamp.svg)](https://microbadger.com/images/ibrt/lamp)

This Docker image contains a full Apache2/PHP/MySQL stack for local development purposes. For simplicity, it runs all services in a single container and mounts a single volume. It is designed to work on macOS using a recent Docker for Mac (note that the older boot2docker and Docker Machine systems are not supported).

%SOFTWARE_VERSIONS%

### Getting Started

Running `ibrt/lamp` requires a project directory to be created on the host machine and mounted under `/project`. Initially the project directory will only contain a `lamp.env` configuration file, usually empty. On the first run, the image will generate configuration values such as a new MySQL root password, write them to the configuration file, and create web and MySQL data directories. After the first run, the project directory will contain the following:

```
$ ls my-project

my-project/
├── lamp.env # project configuration file
├── app/
│   └── web/ # Apache2 web dir
|       └── index.php # welcome page
└── mysql/ # MySQL data dir
    ├── ...
    └── ...
```

The `lamp.env` configuration file will contain the MySQL root password for this project. In future versions of `ibrt/lamp`, additional values may be added.

```
$ cat my-project/lamp.env

MYSQL_PASSWORD="..."
```

Let's get started:

```
$ mkdir my-project && touch my-project/lamp.env
$ docker run -p "3306:3306" -p "80:80" -v "${PWD}/my-project:/project" --name my-project ibrt/lamp
```

If everything goes well, navigating to `http://localhost` should display a welcome page. Additionally, `/phpinfo` should display a `phpinfo();` page, and it should be possible to log into `/phpmyadmin` as root, using the password found in the `lamp.env` file. It should also be possible to connect to MySQL on `localhost:3306`.

### Interacting with the Container

##### Stopping and Restarting

The container can be cleanly stopped using `docker stop` or `Ctrl+C` (if not detached). It can then be restarted using the same command described in the previous section. Existing web and MySQL data directories are left untouched on startup.

##### Working on Multiple Projects

It is of course possible to run multiple instances of the container, provided they mount different project directories. To do so, bind ports 80 and 3306 of the container to different ports on the host:

```
$ docker run -p "33001:3306" -p "8001:80" -v "${PWD}/project-1:/project" --name project-1 ibrt/lamp
$ docker run -p "33002:3306" -p "8002:80" -v "${PWD}/project-2:/project" --name project-2 ibrt/lamp
```

##### Attaching a Shell

Docker for Mac automagically changes permissions for files and directories in mounted volumes. On the host, any file created from within the container will be owned by the host user. Inside the container, any file in the mounted volume will appear to be owned by the same user and group of the process accessing it, whether it is a shell or a system service.

It is possible to attach a shell to a running container using one of the following commands:

```
$ docker exec -it my-project bash
$ docker exec -it my-project setuser www-data bash
```

The former starts a root shell, while the latter starts a non-root shell. Some tools such as Composer will complain when running as root... Besides that there's no real downside to using a root shell, as any change outside the project directory will be lost when the container is stopped.

##### Accessing Logs

The following commands print out respectively the Apache2 access log, the Apache2 error log (which also contains PHP errors), and the MySQL error log:

```
$ docker exec -it my-project cat /var/log/apache2/access.log
$ docker exec -it my-project cat /var/log/apache2/error.log
$ docker exec -it my-project cat /var/log/mysql/error.log
```

##### Choosing the MySQL Root Password

It is possible to choose a MySQL root password by adding it to the `lamp.env` configuration file before the container is started on the project for the first time:

```
$ mkdir my-project && touch my-project/lamp.env
$ echo 'MYSQL_PASSWORD="<my-password>"' > my-project/lamp.env
$ docker run -p "3306:3306" -p "80:80" -v "${PWD}/my-project:/project" --name my-project ibrt/lamp
```

##### Dumping and Restoring MySQL Databases

The `mysqldump` and `mysql` utilities are included in the image and can be used to dump and restore MySQL databases while the container is running. Here is a basic example:

```
$ docker exec -i my-project mysqldump --password=my-password --databases my-db > my-db.sql
$ docker exec -i my-project mysql --password=my-password < my-db.sql
```
