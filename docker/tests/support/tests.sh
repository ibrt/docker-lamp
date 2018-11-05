#!/usr/bin/env sh

for i in $(seq 1 5); do
  echo "Waiting for container..."
  curl -f -s http://lamp > /dev/null
  RESULT=$?

  if [ "$RESULT" -eq "0" ]; then
    break
  else
    sleep 2
  fi
done

if [ "$RESULT" -ne "0" ]; then
  exit "$RESULT"
fi

set -e

echo "Checking '/'..."
curl -f --progress http://lamp > /dev/null

echo "Checking '/docs'..."
curl -f --progress http://lamp/docs > /dev/null

echo "Checking '/phpinfo'..."
curl -f --progress http://lamp/phpinfo > /dev/null

echo "Checking '/phpmyadmin'..."
curl -f --progress http://lamp/phpmyadmin > /dev/null
