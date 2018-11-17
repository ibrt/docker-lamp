#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cat "$DIR/readme.md.tpl" | sed -e '/%VERSIONS%/ {' -e "r $DIR/tags.md.tpl" -e 'd' -e '}' > "$DIR/../README.md"
cat "$DIR/readme.md.tpl" | pandoc -f markdown -t html -s --metadata pagetitle="ibrt/lamp" -H "$DIR/css.html.tpl" | sed -e '/%VERSIONS%/ {' -e "r $DIR/versions.php.tpl" -e 'd' -e '}' > "$DIR/../docker/support/docs.php"
