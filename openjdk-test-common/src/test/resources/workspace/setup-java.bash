#!/bin/bash

function cleanEnv() {
  unset JAVA_OPTS TMPDIR GAE_MEMORY_MB HEAP_SIZE_MB JAVA_HEAP_OPTS JAVA_GC_OPTS JAVA_OPTS DBG_AGENT PROFILER_AGENT
}

cleanEnv

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
cleanEnv
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-showversion -Djava.io.tmpdir=/var/tmp -Xms800M -Xmx800M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+PrintCommandLineFlags" ]; then
  echo "Bad values JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

cleanEnv
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
HEAP_SIZE_MB=500
source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-showversion -Djava.io.tmpdir=/var/tmp -Xms500M -Xmx500M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+PrintCommandLineFlags" ]; then
  echo "Bad values JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi


# test direct OPTS
cleanEnv
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
HEAP_SIZE_MB=500
JAVA_TMP_OPTS=-XX:Temp
JAVA_HEAP_OPTS=-XX:Heap
JAVA_GC_OPTS=-XX:GC
PROFILER_AGENT=profiler
JAVA_USER_OPTS=user

source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-showversion -XX:Temp profiler -XX:Heap -XX:GC user" ]; then
  echo "Bad opts JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

#test override
cleanEnv
TMPDIR=/var/tmp
GAE_MEMORY_MB=1000
HEAP_SIZE_MB=500
JAVA_TMP_OPTS=-XX:Temp
JAVA_HEAP_OPTS=-XX:Heap
JAVA_GC_OPTS=-XX:GC
JAVA_USER_OPTS=user
JAVA_OPTS=-XX:options

source /setup-env.d/30-java-env.bash
if [ "$(echo $JAVA_OPTS | xargs)" != "-XX:options" ]; then
  echo "Bad opts JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi


# test heap size ratio
cleanEnv
GAE_MEMORY_MB=1000
HEAP_SIZE_RATIO=50
source /setup-env.d/30-java-env.bash

TEST_MIN_HEAP=$(echo $JAVA_OPTS | sed 's/.*-Xms500M .*/OK/')
TEST_MAX_HEAP=$(echo $JAVA_OPTS | sed 's/.*-Xmx500M .*/OK/')

if [ "$TEST_MIN_HEAP" != "OK" -o "$TEST_MAX_HEAP" != "OK" ]; then
  echo "Bad values JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi


#test GKE environment
cleanEnv
TMPDIR=/var/tmp
KUBERNETES_MEMORY_LIMIT=20000000
HEAP_SIZE_RATIO=30
source /setup-env.d/30-java-env.bash

TEST_MIN_HEAP=$(echo $JAVA_OPTS | sed 's/.*-Xms5M .*/OK/')
TEST_MAX_HEAP=$(echo $JAVA_OPTS | sed 's/.*-Xmx5M .*/OK/')

if [ "$TEST_MIN_HEAP" != "OK" -o "$TEST_MAX_HEAP" != "OK" ]; then
  echo "Memory limit set by kubernetes is not considered in JAVA_OPTS='$(echo $JAVA_OPTS | xargs)'"
  exit 1
fi

echo OK
