#!/bin/bash

wrapper="/shutdown/shutdown-wrapper.bash"

function doTest() {
  test_setup="testing SHUTDOWN_LOGGING_THREAD_DUMP=$SHUTDOWN_LOGGING_THREAD_DUMP, " \
         "SHUTDOWN_LOGGING_HEAP_INFO=$SHUTDOWN_LOGGING_HEAP_INFO, " \
         "SHUTDOWN_LOGGING_SAMPLE_THRESHOLD=$SHUTDOWN_LOGGING_SAMPLE_THRESHOLD."
  expected=$1
  set - java
  JAVA_OPTS=" "
  source /shutdown/shutdown-env.bash > /dev/null
  if [ "$(echo $@ | xargs)" != "$expected" ]; then
    echo $test_setup
    echo "command='$(echo $@ | xargs)' rather than expected '$expected'"
    echo FAILED
    exit 1
  fi
}

function cleanEnv() {
  unset SHUTDOWN_LOGGING_THREAD_DUMP
  unset SHUTDOWN_LOGGING_HEAP_INFO
  unset SHUTDOWN_LOGGING_SAMPLE_THRESHOLD
}

# default - no shutdown wrapper
cleanEnv
doTest "java"

# thread dump on
cleanEnv
SHUTDOWN_LOGGING_THREAD_DUMP=True
doTest "$wrapper java"

# heap info on
cleanEnv
SHUTDOWN_LOGGING_HEAP_INFO=True
doTest "$wrapper java"

# thread dump and heap info off
cleanEnv
SHUTDOWN_LOGGING_THREAD_DUMP=False
SHUTDOWN_LOGGING_HEAP_INFO=False
doTest "java"

# both on
cleanEnv
SHUTDOWN_LOGGING_THREAD_DUMP=True
SHUTDOWN_LOGGING_HEAP_INFO=True
doTest "$wrapper java"

# both on but threshold 0
cleanEnv
SHUTDOWN_LOGGING_THREAD_DUMP=True
SHUTDOWN_LOGGING_HEAP_INFO=True
SHUTDOWN_LOGGING_SAMPLE_THRESHOLD=0
doTest "java"

# both on but threshold 100
cleanEnv
SHUTDOWN_LOGGING_THREAD_DUMP=True
SHUTDOWN_LOGGING_HEAP_INFO=True
SHUTDOWN_LOGGING_SAMPLE_THRESHOLD=100
doTest "$wrapper java"

echo OK