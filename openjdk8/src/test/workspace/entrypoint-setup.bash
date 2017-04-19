#!/bin/bash
set -- java one two three
JAVA_OPTS="-java -options"

trap "rm -f /setup-env.d/01-one.bash /setup-env.d/02-two.bash /setup-env.d/03-three.bash" EXIT

cat << 'EOF' > /setup-env.d/01-one.bash
export ONE=OK
set -- $(echo $@ | sed 's/one/1/')
EOF

cat << 'EOF' > /setup-env.d/02-two.bash
export TWO=$ONE
set -- $(echo $@ | sed 's/two/2/')
EOF

cat << 'EOF' > /setup-env.d/03-three.bash
export THREE=$TWO
set -- $(echo $@ | sed 's/three/3/')
EOF

sed -e 's/exec /# /' -e 's/set - /set -- /' /docker-entrypoint.bash > /tmp/entrypoint.bash

source /tmp/entrypoint.bash
if [ "$(echo $@ | xargs)" != "java -java -options 1 2 3" ]; then
  echo "@='$(echo $@ | xargs)'"
elif [ "$THREE" != "OK" ]; then
  echo setup out of order $ONE, $TWO, $THREE
else
  echo OK
fi
