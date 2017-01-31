#!/bin/bash

# source the supported feature JVM arguments
source /setup-env.bash

# If the first argument is the java command
if [ "java" = "$1" -o "$(which java)" = "$1" ] ; then
  # ignore it as java is the default command
  shift
fi

# If the first argument is not executable
if ! type "$1" &>/dev/null; then
  # then treat all arguments as arguments to the java command

  # set the command line to java with the feature arguments and passed arguments
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
  exec "$@"
fi
