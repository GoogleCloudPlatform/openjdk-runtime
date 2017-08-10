#!/bin/bash
set - one two three
JAVA_OPTS="-java -options"
sed 's/exec /# /' /docker-entrypoint.bash > /tmp/entrypoint.bash
source /tmp/entrypoint.bash
if [ "$(echo $@ | xargs)" != "java -java -options one two three" ]; then
  echo "@='$(echo $@ | xargs)'"
else
  echo OK
fi
