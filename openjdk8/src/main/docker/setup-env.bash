#!/bin/bash

isTrue() {  
  if [[ ${1,,*} = "true" ]] ;then 
    return ${true}
  else 
    return ${false}
  fi 
}

# detect execution platform
if [ -z "$PLATFORM" ]; then
  if [ -n "$GAE_INSTANCE" ]; then
    PLATFORM=gae
  else
    PLATFORM=unkown
  fi
fi
export PLATFORM

# configure Cloud Debugger
if [ "$PLATFORM" = "gae" ]; then
  export DBG_AGENT=
  export DBG_ENABLE=${DBG_ENABLE:-$( if [[ -z "${CDBG_DISABLE}" && -x /opt/cdbg/format-env-appengine-vm.sh ]] ; then echo true; else echo false ; fi )}
fi

if isTrue "${DBG_ENABLE}" ; then
  unset CDBG_DISABLE
  DBG_AGENT="$( RUNTIME_DIR=$JETTY_BASE /opt/cdbg/format-env-appengine-vm.sh )"
fi

# Setup default Java Options
export JAVA_TMP_OPTS=${JAVA_TMP_OPTS:-$( if [[ -z ${TMPDIR} ]]; then echo ""; else echo "-Djava.io.tmpdir=$TMPDIR"; fi)}
export GAE_MEMORY_MB=${GAE_MEMORY_MB:-$(awk '/MemTotal/{ print int($2/1024-400) }' /proc/meminfo)}
export HEAP_SIZE_MB=${HEAP_SIZE_MB:-$(expr ${GAE_MEMORY_MB} \* 80 / 100)}
export JAVA_HEAP_OPTS=${JAVA_HEAP_OPTS:-"-Xms${HEAP_SIZE_MB}M -Xmx${HEAP_SIZE_MB}M"}
export JAVA_GC_OPTS=${JAVA_GC_OPTS:-"-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+PrintCommandLineFlags"}
export JAVA_OPTS=${JAVA_OPTS:--showversion ${JAVA_TMP_OPTS} ${DBG_AGENT} ${JAVA_HEAP_OPTS} ${JAVA_GC_OPTS} ${JAVA_USER_OPTS}}
