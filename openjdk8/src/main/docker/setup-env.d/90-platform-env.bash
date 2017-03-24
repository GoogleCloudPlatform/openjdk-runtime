#!/bin/bash

# This script uses heuristics to determine what environment an image is 
# running on and then calls all the setup bash scripts in the appropriate
# directory.

if [ -z "$PLATFORM" ]; then
  if [ -n "$GAE_INSTANCE" ]; then
    PLATFORM=gae
  elif [ $( env | egrep '^AWS_' | wc -l ) -gt 0 ]; then
    PLATFORM=aws
  elif [ -n "$DYNO" ]; then
    PLATFORM=heroku
  else
    PLATFORM=local
  fi
fi
export PLATFORM

if [ -d "${SETUP_ENV}/platform-${PLATFORM}.d" ]; then
  for SCRIPT in $( ls ${SETUP_ENV}/platform-${PLATFORM}.d/[0-9]*.bash | sort ) ; do
    source ${SCRIPT}
  done
fi
