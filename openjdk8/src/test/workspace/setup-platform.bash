#!/bin/bash

#test default
unset PLATFORM GAE_INSTANCE
source /setup-env.d/10-platform-env.bash
if [ "$PLATFORM" != "unknown" ]; then
  echo "Bad default PLATFORM='$PLATFORM'"
  exit 1
fi

#test GAE
unset PLATFORM GAE_INSTANCE
GAE_INSTANCE=12345
source /setup-env.d/10-platform-env.bash
if [ "$PLATFORM" != "gae" ]; then
  echo "Bad gae PLATFORM='$PLATFORM'"
  exit 1
fi

#test forced
unset PLATFORM GAE_INSTANCE
GAE_INSTANCE=12345
PLATFORM=special
source /setup-env.d/10-platform-env.bash
if [ "$PLATFORM" != "special" ]; then
  echo "Bad forced PLATFORM='$PLATFORM'"
  exit 1
fi


echo OK
