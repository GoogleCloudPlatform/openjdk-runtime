#!/bin/bash

# If the first argument is the if full java command
if [ "$(which java)" = "$1" ] ; then
  #normalize it
  shift
  set -- java "$@"
# else if the first argument is not executable assume java
elif ! type "$1" &>/dev/null; then
  set -- java "$@"
fi

# scan the setup-env.d directory for scripts to source for additional setup
if [ -d "${SETUP_ENV:=/setup-env.d}" ]; then
  for SCRIPT in $( ls "${SETUP_ENV}/"[0-9]*.bash | sort ) ; do
    source ${SCRIPT}
  done
fi

# Do we have JAVA_OPTS for a java command?
if [ "$1" = "java" -a -n "$JAVA_OPTS" ]; then
  shift
  set -- java $JAVA_OPTS "$@"
fi

# exec the entry point arguments as a command
exec "$@"

