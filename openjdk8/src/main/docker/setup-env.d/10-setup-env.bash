#!/bin/bash

isTrue() {  
  if [[ ${1,,*} = "true" ]] ;then 
    return ${true}
  else 
    return ${false}
  fi 
}


if [ -z "$PLATFORM" ]; then
  if [ -n "$GAE_INSTANCE" ]; then
    PLATFORM=gae
  else
    PLATFORM=unknown
  fi
fi
export PLATFORM

