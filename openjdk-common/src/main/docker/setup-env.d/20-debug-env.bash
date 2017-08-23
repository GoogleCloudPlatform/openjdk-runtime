#!/bin/bash

# configure Cloud Debugger

export DBG_SCRIPT_PATH=${DBG_SCRIPT_PATH:-"/opt/cdbg/format-env-appengine-vm.sh"}

if [ "$PLATFORM" = "gae" ]; then
  export DBG_AGENT=
  export DBG_ENABLE=${DBG_ENABLE:-$( if [[ -z "${CDBG_DISABLE}" && -x "${DBG_SCRIPT_PATH}" ]] ; then echo true; else echo false ; fi )}
fi

if is_true "$DBG_ENABLE"; then
  unset CDBG_DISABLE
  DBG_AGENT="$($DBG_SCRIPT_PATH)"
fi
