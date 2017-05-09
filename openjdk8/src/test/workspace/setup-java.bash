#!/bin/bash
unset JAVA_OPTS TMPDIR GAE_MEMORY_MB HEAP_SIZE_MB JAVA_HEAP_OPTS JAVA_GC_OPTS JAVA_OPTS DBG_AGENT

#test default
source /setup-env.d/30-java-env.bash


TEST=$(echo $JAVA_OPTS | sed 's/^-showversion.*/OK/')
if [ "$TEST" != "OK" ]; then
  echo "Show version JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

TEST=$(echo $JAVA_OPTS | sed 's/.*-Xms.*/OK/')
if [ "$TEST" != "OK" ]; then
  echo "No Xms JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

TEST=$(echo $JAVA_OPTS | sed 's/.*-XX:+ParallelRefProcEnabled.*/OK/')
if [ "$TEST" != "OK" ]; then
  echo "No XX:ParallelRefProc JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

TEST=$(echo $JAVA_OPTS | sed 's/.*-XX:.UseG1GC.*/OK/')
if [ "$TEST" != "OK" ]; then
  echo "No XX:UseG1GC JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi


# test base values
unset JAVA_OPTS TMPDIR GAE_MEMORY_MB HEAP_SIZE_MB JAVA_HEAP_OPTS JAVA_GC_OPTS JAVA_OPTS DBG_AGENT
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-showversion -Djava.io.tmpdir=/var/tmp -Xms800M -Xmx800M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+PrintCommandLineFlags" ]; then
  echo "Bad values JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

unset JAVA_OPTS TMPDIR GAE_MEMORY_MB HEAP_SIZE_MB JAVA_HEAP_OPTS JAVA_GC_OPTS JAVA_OPTS DBG_AGENT
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
HEAP_SIZE_MB=500
source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-showversion -Djava.io.tmpdir=/var/tmp -Xms500M -Xmx500M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+PrintCommandLineFlags" ]; then
  echo "Bad values JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi


# test direct OPTS
unset JAVA_OPTS TMPDIR GAE_MEMORY_MB HEAP_SIZE_MB JAVA_HEAP_OPTS JAVA_GC_OPTS JAVA_OPTS DBG_AGENT
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
HEAP_SIZE_MB=500
JAVA_TMP_OPTS=-XX:Temp
JAVA_HEAP_OPTS=-XX:Heap
JAVA_GC_OPTS=-XX:GC
DBG_AGENT=debug
JAVA_USER_OPTS=user

source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-showversion -XX:Temp debug -XX:Heap -XX:GC user" ]; then
  echo "Bad opts JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

#test override
unset JAVA_OPTS TMPDIR GAE_MEMORY_MB HEAP_SIZE_MB JAVA_HEAP_OPTS JAVA_GC_OPTS JAVA_OPTS DBG_AGENT
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
HEAP_SIZE_MB=500
JAVA_TMP_OPTS=-XX:Temp
JAVA_HEAP_OPTS=-XX:Heap
JAVA_GC_OPTS=-XX:GC
DBG_AGENT=debug
JAVA_USER_OPTS=user
JAVA_OPTS=-XX:options

source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-XX:options" ]; then
  echo "Bad opts JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi


# test heap size ratio
unset JAVA_OPTS TMPDIR GAE_MEMORY_MB HEAP_SIZE_MB JAVA_HEAP_OPTS JAVA_GC_OPTS JAVA_OPTS DBG_AGENT
GAE_MEMORY_MB=1000
HEAP_SIZE_RATIO=50
source /setup-env.d/30-java-env.bash

TEST_MIN_HEAP=$(echo $JAVA_OPTS | sed 's/.*-Xms500.*/OK/')
TEST_MAX_HEAP=$(echo $JAVA_OPTS | sed 's/.*-Xmx500.*/OK/')

if [ "$TEST_MIN_HEAP" != "OK" -o "$TEST_MAX_HEAP" != "OK" ]; then
  echo "Bad values JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

echo OK
