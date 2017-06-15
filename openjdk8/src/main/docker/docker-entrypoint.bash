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

# If configured, output a thread dump and/or heap info on shutdown by wrapping the java process
if is_true "${SHUTDOWN_LOGGING_THREAD_DUMP}" || is_true "${SHUTDOWN_LOGGING_HEAP_INFO}"; then
  # default shutdown logging sample threshold is 100 (100%)
  export SHUTDOWN_LOGGING_SAMPLE_THRESHOLD=${SHUTDOWN_LOGGING_SAMPLE_THRESHOLD:-100}
  random_sample=$(( RANDOM % 100 ))
  if (( random_sample <  SHUTDOWN_LOGGING_SAMPLE_THRESHOLD)); then
    echo "Shutdown logging threshold of ${SHUTDOWN_LOGGING_SAMPLE_THRESHOLD}% satisfied with sample ${random_sample}."
    set -- /shutdown-wrapper.bash "$@"
  else
    echo "Shutdown logging threshold of ${SHUTDOWN_LOGGING_SAMPLE_THRESHOLD}% NOT satisfied with sample ${random_sample}."
  fi
fi

# exec the entry point arguments as a command
echo "Start command: $@"
exec "$@"
