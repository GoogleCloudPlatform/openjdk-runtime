#!/bin/bash

# If the first argument is the java command
if [ "java" = "$1" -o "$(which java)" = "$1" ] ; then
  # The default command java is added below, so remove java here before
  # setup customization.  It will be added below if the resulting 
  # command line is not executable
  shift
fi

# scan the setup-env.d directory for scripts to source for additional setup
if [ -d "${SETUP_ENV:=/setup-env.d}" ]; then
  for SCRIPT in $( ls "${SETUP_ENV}/"[0-9]*.bash | sort ) ; do
    source ${SCRIPT}
  done
fi

# If the first argument is not executable
if ! type "$1" &>/dev/null; then
  # then treat all arguments as arguments to the java command
  
  # set the command line to java with the feature arguments and passed arguments
  set -- java $JAVA_OPTS "$@"
fi

# exec the entry point arguments as a command
exec "$@"

