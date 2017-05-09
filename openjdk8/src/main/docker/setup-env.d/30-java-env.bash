#!/bin/bash

GetAvailableMemory () {
  if [ -n "$MEMORY_LIMIT" ]; then
    # As Kubernetes give the memory in byte we have to convert it to MB
    echo $((MEMORY_LIMIT / 1000000))
  else
    echo "$(awk '/MemTotal/{ print int($2/1024-400) }' /proc/meminfo)"
  fi
}

# Setup default Java Options
export JAVA_TMP_OPTS=${JAVA_TMP_OPTS:-$( if [[ -z ${TMPDIR} ]]; then echo ""; else echo "-Djava.io.tmpdir=$TMPDIR"; fi)}
export GAE_MEMORY_MB=${GAE_MEMORY_MB:-$(GetAvailableMemory)}
export HEAP_SIZE_RATIO=${HEAP_SIZE_RATIO:-"80"}
export HEAP_SIZE_MB=${HEAP_SIZE_MB:-$(expr ${GAE_MEMORY_MB} \* ${HEAP_SIZE_RATIO} / 100)}
export JAVA_HEAP_OPTS=${JAVA_HEAP_OPTS:-"-Xms${HEAP_SIZE_MB}M -Xmx${HEAP_SIZE_MB}M"}
export JAVA_GC_OPTS=${JAVA_GC_OPTS:-"-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+PrintCommandLineFlags"}
export JAVA_OPTS=${JAVA_OPTS:--showversion ${JAVA_TMP_OPTS} ${DBG_AGENT} ${JAVA_HEAP_OPTS} ${JAVA_GC_OPTS} ${JAVA_USER_OPTS}}
