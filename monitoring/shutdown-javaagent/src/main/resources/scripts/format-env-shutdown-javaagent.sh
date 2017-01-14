#!/bin/bash
#Disable shutdown logging if shutdown_logging_disable is true
if [ "${SHUTDOWN_LOGGING_DISABLE}" = "true" ] ; then
  echo ""
  exit 0
fi

#Local environment : use environment variable, app engine : retrieve from project metadata
if [ "$GAE_PARTITION" != "dev" ] ; then
  SHUTDOWN_LOGGING_ENABLE=`wget --header="Metadata-Flavor: Google" -qO- http://metadata.google.internal/computeMetadata/v1/project/attributes/SHUTDOWN_LOGGING_ENABLE`
fi

#Enable or disable java agent : use SHUTDOWN_LOGGING_THREAD_DUMP, SHUTDOWN_LOGGING_HEAP_INFO environment variables to override thread_dump and heap_info values
if [ "${SHUTDOWN_LOGGING_ENABLE}" = "false" ] ; then
  ARGS=""
elif [ "${SHUTDOWN_LOGGING_ENABLE}" = "true" ] ; then
  ARGS="-javaagent:/opt/agents/shutdown-javaagent.jar=thread_dump=false;heap_info=true"
fi
echo "${ARGS}"
