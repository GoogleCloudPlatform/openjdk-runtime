#!/bin/bash

is_java_cmd() {
  [ "$(which java)" = "$1" -o "$(readlink -f $(which java))" = "$1" ]
}

# Normalize invocations of "java" so that other scripts can more easily detect it
if is_java_cmd "$1"; then
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

# Normalize invocations of "java" again in case other scripts have modified it
if is_java_cmd "$1"; then
  shift
  set -- java "$@"
fi

# Do we have JAVA_OPTS for a java command?
if [ "$1" = "java" -a -n "$JAVA_OPTS" ]; then
  shift
  set -- java $JAVA_OPTS "$@"
fi

# If configured, output a thread dump on shutdown
if isTrue "${SHUTDOWN_THREAD_DUMP_ENABLE}"
then
  # capture the TERM signal and send a QUIT first to generate the thread dump
  export THREAD_DUMP_FILE=${THREAD_DUMP_FILE:-/var/log/app_engine/app-shutdown.log}
  trap 'kill -QUIT $PID; jstack $PID >> $THREAD_DUMP_FILE 2>&1; kill -TERM $PID' TERM
  $@ &
  PID=$!
  wait $PID
  wait $PID
  exit $?
else
  # exec the entry point arguments as a command
  echo "Start command: $@"
  exec "$@"
fi