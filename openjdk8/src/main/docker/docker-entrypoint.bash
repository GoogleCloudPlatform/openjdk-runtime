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

# If configured, output a thread dump and/or heap info on shutdown
if [ "${SHUTDOWN_LOGGING_THREAD_DUMP}" = "true" -o "${SHUTDOWN_LOGGING_HEAP_INFO}" = "true" ]; then
  exec shutdown-wrapper.bash "$@"
else
  # exec the entry point arguments as a command
  exec "$@"
fi
