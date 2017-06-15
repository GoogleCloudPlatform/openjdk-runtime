#!/bin/bash

function java_shutdown_hook {
  # send thread dump to a file
  if is_true "${SHUTDOWN_LOGGING_THREAD_DUMP}"; then
    export THREAD_DUMP_FILE=${THREAD_DUMP_FILE:-/app.shutdown.threads}
    jcmd $PID Thread.print  >> $THREAD_DUMP_FILE 2>&1
  fi

  # send heap info to a file
  if is_true "${SHUTDOWN_LOGGING_HEAP_INFO}"; then
    export HEAP_INFO_FILE=${HEAP_INFO_FILE:-/app.shutdown.heap}
    jcmd $PID GC.class_histogram >> $HEAP_INFO_FILE 2>&1
  fi
}

# capture the TERM signal and first generate the thread dump and/or heap info
trap 'java_shutdown_hook; kill -TERM $PID' TERM
$@ &
PID=$!
wait $PID
wait $PID
if is_true "${SHUTDOWN_LOGGING_THREAD_DUMP}"; then
  # output thread dump to stdout
  echo '~~~~~~~~~~~~~~~~~~~~~~ THREAD DUMP ~~~~~~~~~~~~~~~~~~~~~~'
  cat $THREAD_DUMP_FILE
fi
if is_true "${SHUTDOWN_LOGGING_HEAP_INFO}"; then
  # output abbreviated heap info to stdout
  echo '~~~~~~~~~~~~~~~~~~~~~~~ HEAP INFO ~~~~~~~~~~~~~~~~~~~~~~~'
  heap_total_lines=`wc -l < $HEAP_INFO_FILE`
  HEAP_SHOW_LINES_COUNT=${HEAP_SHOW_LINES_COUNT:-54}
  head -"$HEAP_SHOW_LINES_COUNT" $HEAP_INFO_FILE
  echo "[$(( heap_total_lines - HEAP_SHOW_LINES_COUNT - 1 )) lines omitted]"
  tail -1 $HEAP_INFO_FILE
fi
exit $?