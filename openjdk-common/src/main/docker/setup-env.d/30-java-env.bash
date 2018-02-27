#!/bin/bash

GetAvailableMemory () {
  local default_memory="$(awk '/MemTotal/{ print int($2/1024-400) }' /proc/meminfo)"
  local memory=""

  # Search for a memory limit set by kubernetes
  if [ -n "$KUBERNETES_MEMORY_LIMIT" ]; then
    memory=$((KUBERNETES_MEMORY_LIMIT / (1024 * 1024)))
  fi

  # Search for a memory limit set by cgroup
  local cgroup_mem_file="/sys/fs/cgroup/memory/memory.limit_in_bytes"
  if [ -z $memory ] && [ -r "$cgroup_mem_file" ]; then
    local cgroup_memory="$(cat ${cgroup_mem_file})"
    cgroup_memory=$((cgroup_memory / (1024 * 1024)))
    # Cgroup memory can be 0 or unbound, in which case we use the default limit
    if [ ${cgroup_memory} -gt 0 ] && [ ${cgroup_memory} -lt ${default_memory} ]; then
      memory=$cgroup_memory
    fi
  fi

  # Fallback to default memory limit
  if [ -z $memory ]; then
    memory=$default_memory
  fi

  echo $memory
}

# Setup default Java Options
export JAVA_TMP_OPTS=${JAVA_TMP_OPTS:-$( if [[ -z ${TMPDIR} ]]; then echo ""; else echo "-Djava.io.tmpdir=$TMPDIR"; fi)}
export GAE_MEMORY_MB=${GAE_MEMORY_MB:-$(GetAvailableMemory)}
export HEAP_SIZE_RATIO=${HEAP_SIZE_RATIO:-"80"}
export HEAP_SIZE_MB=${HEAP_SIZE_MB:-$(expr ${GAE_MEMORY_MB} \* ${HEAP_SIZE_RATIO} / 100)}
export JAVA_HEAP_OPTS=${JAVA_HEAP_OPTS:-"-Xms${HEAP_SIZE_MB}M -Xmx${HEAP_SIZE_MB}M"}
export JAVA_GC_OPTS=${JAVA_GC_OPTS:-"-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+PrintCommandLineFlags"}
export JAVA_OPTS=${JAVA_OPTS:--showversion ${JAVA_TMP_OPTS} ${DBG_AGENT} ${PROFILER_AGENT} ${JAVA_HEAP_OPTS} ${JAVA_GC_OPTS} ${JAVA_USER_OPTS}}
