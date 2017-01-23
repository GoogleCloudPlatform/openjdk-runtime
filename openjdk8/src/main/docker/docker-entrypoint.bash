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


if [ -z "$SHUTDOWN_THREAD_DUMP" ]
then
  # exec the entry point arguments as a command
  exec "$@"
else
  # capture the TERM signal and send a SIGQUIT first to generate the thread dump
  trap 'kill -3 $PID; kill $PID' TERM
  $@ &
  PID=$!
  wait $PID
  wait $PID
  exit $?
fi
