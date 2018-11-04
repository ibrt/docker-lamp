#!/bin/bash

set -e
echo -e "\n---\nDocker LAMP init..."
trap "{ echo -e "---\\\\n"; }" EXIT

# Check ENV file.
if [ ! -f "/project/lamp.env" ]; then
  echo "ERROR: Please init and mount project dir. See https://github.com/ibrt/docker-lamp for instructions."
  exit 1
fi

# Load ENV file.
source "/project/lamp.env"

# Check MYSQL_PASSWORD, generate if needed.
if [ ! -n "$MYSQL_PASSWORD" ]; then
  echo "Generating MySQL root password..."
  MYSQL_PASSWORD="$(pwgen -s 12 1)"
  echo "MYSQL_PASSWORD=\"${MYSQL_PASSWORD}\"" > "/project/lamp.env"
fi

# Check MySQL data dir, initialize if needed.
if [ ! -d "/project/mysql" ]; then
  echo "Initializing MySQL database..."
  cp "/usr/share/phpmyadmin/sql/create_tables.sql" "/tmp/init.sql"
  MYSQL_PASSWORD="$MYSQL_PASSWORD" envsubst < "/usr/share/init.sql.tpl" >> "/tmp/init.sql"  
  mkdir -p "/project/mysql"
  mysqld --initialize-insecure --init-file "/tmp/init.sql"
  rm "/tmp/init.sql"
fi

# Check web dir, initialize if needed.
if [ ! -d "/project/app/web" ]; then
  echo "Initializing web dir..."
  mkdir -p "/project/app/web"
  ln -s "/usr/share/docs/index.php" "/project/app/web/index.php"
fi

# Final touches.
sed -i "s/^\$cfg\['blowfish_secret'\].*/\$cfg['blowfish_secret'] = '$(pwgen -s 32 1)';/" /usr/share/phpmyadmin/config.inc.php