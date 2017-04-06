#!/bin/bash

if [ -z "$PLATFORM" ]; then
  if [ -n "$GAE_INSTANCE" ]; then
    PLATFORM=gae
  else
    PLATFORM=unknown
  fi
fi
export PLATFORM

