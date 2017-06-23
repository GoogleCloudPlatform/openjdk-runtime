#!/bin/bash

source /setup-env.d/05-utils.bash

# create dummy cloud debugger script
DBG_SCRIPT_PATH=$(mktemp)
chmod +x ${DBG_SCRIPT_PATH}
echo "echo DBG_ON" > "$DBG_SCRIPT_PATH"

function testDebuggerOn() {
  source /setup-env.d/20-debug-env.bash
  if [ "$DBG_AGENT" != "DBG_ON" ]; then
    echo "Debugger should be ON because $1"
    exit 1
  fi
}

function testDebuggerOff() {
  source /setup-env.d/20-debug-env.bash
  if [ "$DBG_AGENT" != "" ]; then
    echo "Debugger should be OFF because $1"
    exit 1
  fi
}

function cleanEnv() {
  unset DBG_AGENT
  unset DBG_ENABLE
  unset PLATFORM
}

# test default - debugger OFF
cleanEnv
testDebuggerOff "that's the default"

# test GAE default - debugger ON
cleanEnv
PLATFORM=gae
testDebuggerOn "that's the default on GAE"

# test GKE default - debugger OFF
cleanEnv
PLATFORM=gke
testDebuggerOff "that's the default on GKE"

# test DBG_ENABLE = true
cleanEnv
DBG_ENABLE=true
testDebuggerOn "DBG_ENABLE=$DBG_ENABLE"

# test DBG_ENABLE = True
cleanEnv
DBG_ENABLE=True
testDebuggerOn "DBG_ENABLE=$DBG_ENABLE"

# test DBG_ENABLE = false
cleanEnv
DBG_ENABLE=false
testDebuggerOff "DBG_ENABLE=$DBG_ENABLE"

# test DBG_ENABLE = False
cleanEnv
DBG_ENABLE=False
testDebuggerOff "DBG_ENABLE=$DBG_ENABLE"


rm $DBG_SCRIPT_PATH
echo OK
