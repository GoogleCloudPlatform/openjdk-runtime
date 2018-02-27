#!/bin/bash

source /setup-env.d/05-utils.bash

function testProfilerOn() {
  source /setup-env.d/25-profiler-env.bash
  if [ "$PROFILER_AGENT" != "-agentpath:/opt/cprof/profiler_java_agent.so=--logtostderr" ]; then
    echo "Profiler should be ON because $1"
    exit 1
  fi
}

function testProfilerOff() {
  source /setup-env.d/25-profiler-env.bash
  if [ "$PROFILER_AGENT" != "" ]; then
    echo "Profiler should be OFF because $1"
    exit 1
  fi
}

function cleanEnv() {
  unset PROFILER_AGENT
  unset PROFILER_ENABLE
  unset PLATFORM
  unset JAVA_USER_OPTS
}

# test default - profiler OFF
cleanEnv
testProfilerOff "that's the default"

# test GAE default - profiler OFF
cleanEnv
PLATFORM=gae
testProfilerOff "that's the default on GAE"

# test GKE default - profiler OFF
cleanEnv
PLATFORM=gke
testProfilerOff "that's the default on GKE"

# test PROFILER_ENABLE = true
cleanEnv
PROFILER_ENABLE=true
testProfilerOn "PROFILER_ENABLE=$PROFILER_ENABLE"

# test PROFILER_ENABLE = True
cleanEnv
PROFILER_ENABLE=True
testProfilerOn "PROFILER_ENABLE=$PROFILER_ENABLE"

# test PROFILER_ENABLE = false
cleanEnv
PROFILER_ENABLE=false
testProfilerOff "PROFILER_ENABLE=$PROFILER_ENABLE"

# test PROFILER_ENABLE = False
cleanEnv
PROFILER_ENABLE=False
testProfilerOff "PROFILER_ENABLE=$PROFILER_ENABLE"

# test JAVA_USER_OPTS = -agentpath:/opt/cprof/profiler_java_agent.so=--logtostderr
cleanEnv
JAVA_USER_OPTS=-agentpath:/opt/cprof/profiler_java_agent.so=--logtostderr
PROFILER_ENABLE=True
testProfilerOff "JAVA_USER_OPTS=$JAVA_USER_OPTS"

echo OK
