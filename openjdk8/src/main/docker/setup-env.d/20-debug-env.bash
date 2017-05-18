#!/bin/bash

# configure Cloud Debugger
if [ "$PLATFORM" = "gae" ]; then
  export DBG_AGENT=
  export DBG_ENABLE=${DBG_ENABLE:-$( if [[ -z "${CDBG_DISABLE}" && -x /opt/cdbg/format-env-appengine-vm.sh ]] ; then echo true; else echo false ; fi )}
fi

if [ "$DBG_ENABLE" = "true" ]; then
  unset CDBG_DISABLE
  DBG_AGENT="$(/opt/cdbg/format-env-appengine-vm.sh)"
fi
