#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cat "$DIR/readme.md.tpl" | sed 's/%SOFTWARE_VERSIONS%//g' | sed -e '/./b' -e :n -e 'N;s/\n$//;tn' > "$DIR/../README.md"
cat "$DIR/readme.md.tpl" | pandoc -f markdown -t html -s --metadata pagetitle="ibrt/lamp" -H "$DIR/css.html.tpl" | sed -e '/%SOFTWARE_VERSIONS%/ {' -e "r $DIR/versions.php.tpl" -e 'd' -e '}' > "$DIR/../docker/support/docs.php"
