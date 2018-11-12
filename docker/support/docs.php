<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
  <meta charset="utf-8" />
  <meta name="generator" content="pandoc" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
  <title>ibrt/lamp</title>
  <style type="text/css">
      code{white-space: pre-wrap;}
      span.smallcaps{font-variant: small-caps;}
      span.underline{text-decoration: underline;}
      div.column{display: inline-block; vertical-align: top; width: 50%;}
  </style>
  <!--[if lt IE 9]>
    <script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv-printshiv.min.js"></script>
  <![endif]-->
  <style type="text/css">
    body{max-width:768px;margin:0 auto;padding:0 1rem;}
    p{text-align:justify;line-height:1.3;}
    code{white-space:pre!important;line-height:1.3;}
    pre{overflow-x:auto;background-color:#EEEEEE;padding:1em;border-radius:0.5em;}
  </style>
</head>
<body>
<h1 id="ibrtlamp">ibrt/lamp</h1>
<p><a href="https://hub.docker.com/r/ibrt/lamp/builds"><img src="https://img.shields.io/docker/build/ibrt/lamp.svg" alt="Docker Build Status" /></a> <a href="https://microbadger.com/images/ibrt/lamp"><img src="https://images.microbadger.com/badges/image/ibrt/lamp.svg" alt="Docker Image" /></a></p>
<p>This Docker image contains a full Apache2/PHP/MySQL stack for local development purposes. For simplicity, it runs all services in a single container and mounts a single volume. It is designed to work on macOS using a recent Docker for Mac (note that the older boot2docker and Docker Machine systems are not supported).</p>
<table border="1" cellpadding="5">
  <tr><td>OS Version:</td><td><?=exec('lsb_release -ds')?></td></tr>
  <tr><td>Apache Version:</td><td><?=apache_get_version()?></td></tr>
  <tr><td>PHP Version:</td><td><?=phpversion()?></td></tr>
  <tr><td>MySQL Version:</td><td><?=exec('mysqld --version')?></td></tr>
</table><h3 id="getting-started">Getting Started</h3>
<p>Running <code>ibrt/lamp</code> requires a project directory to be created on the host machine and mounted under <code>/project</code>. Initially the project directory will only contain a <code>lamp.env</code> configuration file, usually empty. On the first run, the image will generate configuration values such as a new MySQL root password, write them to the configuration file, and create web and MySQL data directories. After the first run, the project directory will contain the following:</p>
<pre><code>$ ls my-project

my-project/
├── lamp.env # project configuration file
├── app/
│   └── web/ # Apache2 web dir
|       └── index.php # welcome page
└── mysql/ # MySQL data dir
    ├── ...
    └── ...</code></pre>
<p>The <code>lamp.env</code> configuration file will contain the MySQL root password for this project. In future versions of <code>ibrt/lamp</code>, additional values may be added.</p>
<pre><code>$ cat my-project/lamp.env

MYSQL_PASSWORD=&quot;...&quot;</code></pre>
<p>Let’s get started:</p>
<pre><code>$ mkdir my-project &amp;&amp; touch my-project/lamp.env
$ docker run -p &quot;3306:3306&quot; -p &quot;80:80&quot; -v &quot;${PWD}/my-project:/project&quot; --name my-project ibrt/lamp</code></pre>
<p>If everything goes well, navigating to <code>http://localhost</code> should display a welcome page. Additionally, <code>/phpinfo</code> should display a <code>phpinfo();</code> page, and it should be possible to log into <code>/phpmyadmin</code> as root, using the password found in the <code>lamp.env</code> file. It should also be possible to connect to MySQL on <code>localhost:3306</code>.</p>
<h3 id="interacting-with-the-container">Interacting with the Container</h3>
<h5 id="stopping-and-restarting">Stopping and Restarting</h5>
<p>The container can be cleanly stopped using <code>docker stop</code> or <code>Ctrl+C</code> (if not detached). It can then be restarted using the same command described in the previous section. Existing web and MySQL data directories are left untouched on startup.</p>
<h5 id="working-on-multiple-projects">Working on Multiple Projects</h5>
<p>It is of course possible to run multiple instances of the container, provided they mount different project directories. To do so, bind ports 80 and 3306 of the container to different ports on the host:</p>
<pre><code>$ docker run -p &quot;33001:3306&quot; -p &quot;8001:80&quot; -v &quot;${PWD}/project-1:/project&quot; --name project-1 ibrt/lamp
$ docker run -p &quot;33002:3306&quot; -p &quot;8002:80&quot; -v &quot;${PWD}/project-2:/project&quot; --name project-2 ibrt/lamp</code></pre>
<h5 id="attaching-a-shell">Attaching a Shell</h5>
<p>Docker for Mac automagically changes permissions for files and directories in mounted volumes. On the host, any file created from within the container will be owned by the host user. Inside the container, any file in the mounted volume will appear to be owned by the same user and group of the process accessing it, whether it is a shell or a system service.</p>
<p>It is possible to attach a shell to a running container using one of the following commands:</p>
<pre><code>$ docker exec -it my-project bash
$ docker exec -it my-project setuser www-data bash</code></pre>
<p>The former starts a root shell, while the latter starts a non-root shell. Some tools such as Composer will complain when running as root… Besides that there’s no real downside to using a root shell, as any change outside the project directory will be lost when the container is stopped.</p>
<h5 id="accessing-logs">Accessing Logs</h5>
<p>The following commands print out respectively the Apache2 access log, the Apache2 error log (which also contains PHP errors), and the MySQL error log:</p>
<pre><code>$ docker exec -it my-project cat /var/log/apache2/access.log
$ docker exec -it my-project cat /var/log/apache2/error.log
$ docker exec -it my-project cat /var/log/mysql/error.log</code></pre>
<h5 id="choosing-the-mysql-root-password">Choosing the MySQL Root Password</h5>
<p>It is possible to choose a MySQL root password by adding it to the <code>lamp.env</code> configuration file before the container is started on the project for the first time:</p>
<pre><code>$ mkdir my-project &amp;&amp; touch my-project/lamp.env
$ echo &#39;MYSQL_PASSWORD=&quot;&lt;my-password&gt;&quot;&#39; &gt; my-project/lamp.env
$ docker run -p &quot;3306:3306&quot; -p &quot;80:80&quot; -v &quot;${PWD}/my-project:/project&quot; --name my-project ibrt/lamp</code></pre>
<h5 id="dumping-and-restoring-mysql-databases">Dumping and Restoring MySQL Databases</h5>
<p>The <code>mysqldump</code> and <code>mysql</code> utilities are included in the image and can be used to dump and restore MySQL databases while the container is running. Here is a basic example:</p>
<pre><code>$ docker exec -i my-project mysqldump --password=my-password --databases my-db &gt; my-db.sql
$ docker exec -i my-project mysql --password=my-password &lt; my-db.sql</code></pre>
</body>
</html>
