#!/bin/bash

function java_shutdown_hook {
  echo "java_shutdown_hook executing for $PID"

  # thread dump
  if [ "${SHUTDOWN_LOGGING_THREAD_DUMP}" = "true" ]; then
    export THREAD_DUMP_FILE=${THREAD_DUMP_FILE:-/var/log/app_engine/app.shutdown.threads}
    jcmd $PID Thread.print  >> $THREAD_DUMP_FILE 2>&1
  fi

  # heap info
  if [ "${SHUTDOWN_LOGGING_HEAP_INFO}" = "true" ]; then
    export HEAP_INFO_FILE=${HEAP_INFO_FILE:-/var/log/app_engine/app.shutdown.heap}
    jcmd $PID GC.class_histogram >> $HEAP_INFO_FILE 2>&1
  fi
}

# capture the TERM signal and send a QUIT first to generate the thread dump and/or heap info
trap 'kill -QUIT $PID; java_shutdown_hook; kill -TERM $PID' TERM
$@ &
PID=$!
wait $PID
wait $PID
exit $?
