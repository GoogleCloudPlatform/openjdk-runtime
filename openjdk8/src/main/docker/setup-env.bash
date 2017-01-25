#!/bin/bash

isTrue() {  
  if [[ ${1,,*} = "true" ]] ;then 
    return ${true}
  else 
    return ${false}
  fi 
}

export DBG_AGENT=
export DBG_ENABLE=${DBG_ENABLE:-$( if [[ -z "${CDBG_DISABLE}" && -x /opt/cdbg/format-env-appengine-vm.sh ]] ; then echo true; else echo false ; fi )}
if isTrue "${DBG_ENABLE}" ; then
  if [[ "$GAE_PARTITION" = "dev" ]]; then
    echo "Running locally and DBG_ENABLE is set, enabling standard Java debugger agent"
    export DBG_PORT=${DBG_PORT:-5005}
    DBG_AGENT="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=${DBG_PORT}"
  else
    unset CDBG_DISABLE
    DBG_AGENT="$( RUNTIME_DIR=$JETTY_BASE /opt/cdbg/format-env-appengine-vm.sh )"
  fi
fi

# Setup default Java Options
export JAVA_TMP_OPTS=${JAVA_TMP_OPTS:-$( if [[ -z ${TMPDIR} ]]; then echo ""; else echo "-Djava.io.tmpdir=$TMPDIR"; fi)}
export GAE_MEMORY_MB=${GAE_MEMORY_MB:-$(awk '/MemTotal/{ print int($2/1024-400) }' /proc/meminfo)}
export HEAP_SIZE_MB=${HEAP_SIZE_MB:-$(expr ${GAE_MEMORY_MB} \* 80 / 100)}
export JAVA_HEAP_OPTS=${JAVA_HEAP_OPTS:-"-Xms${HEAP_SIZE_MB}M -Xmx${HEAP_SIZE_MB}M"}
export JAVA_GC_OPTS=${JAVA_GC_OPTS:-"-XX:+UseG1GC -XX:+ParallelRefProcEnabled"}
export JAVA_OPTS=${JAVA_OPTS:--showversion ${JAVA_TMP_OPTS} ${DBG_AGENT} ${JAVA_HEAP_OPTS} ${JAVA_GC_OPTS} ${JAVA_USER_OPTS}}
