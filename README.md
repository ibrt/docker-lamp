# ibrt/lamp
[![Docker Build Status](https://img.shields.io/docker/build/ibrt/lamp.svg)](https://hub.docker.com/r/ibrt/lamp/builds)
[![Docker Image](https://images.microbadger.com/badges/image/ibrt/lamp.svg)](https://microbadger.com/images/ibrt/lamp)

This Docker image contains a full Apache2/PHP/MySQL stack for local development purposes. For simplicity, it runs all services in a single container and mounts a single volume. It is designed to work on macOS using the latest Docker for Mac.

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

If everything goes well, navigating to `http://localhost` should display a welcome page. Additionally, `/phpinfo` should display a `phpinfo();` page, and it should be possible to log into `/phpmyadmin` as root, using the password found in the `lamp.env` file.
