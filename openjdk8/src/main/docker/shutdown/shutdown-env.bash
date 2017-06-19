#!/bin/bash

source /setup-env.d/05-utils.bash

# If configured, output a thread dump and/or heap info on shutdown by wrapping the java process
if is_true "${SHUTDOWN_LOGGING_THREAD_DUMP}" || is_true "${SHUTDOWN_LOGGING_HEAP_INFO}"; then
  # default shutdown logging sample threshold is 100 (100%)
  export SHUTDOWN_LOGGING_SAMPLE_THRESHOLD=${SHUTDOWN_LOGGING_SAMPLE_THRESHOLD:-100}
  random_sample=$(( RANDOM % 100 ))
  if (( random_sample <  SHUTDOWN_LOGGING_SAMPLE_THRESHOLD)); then
    echo "Shutdown logging threshold of ${SHUTDOWN_LOGGING_SAMPLE_THRESHOLD}% satisfied with sample ${random_sample}."
    set -- /shutdown/shutdown-wrapper.bash "$@"
  else
    echo "Shutdown logging threshold of ${SHUTDOWN_LOGGING_SAMPLE_THRESHOLD}% NOT satisfied with sample ${random_sample}."
  fi
fi