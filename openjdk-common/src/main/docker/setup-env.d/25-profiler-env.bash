#!/bin/bash

# configure Stackdriver Profiler

export PROFILER_AGENT_COMMAND=${PROFILER_AGENT_COMMAND:-"-agentpath:/opt/cprof/profiler_java_agent.so=--logtostderr"}

export PROFILER_AGENT=

if is_true "$PROFILER_ENABLE"; then
  PROFILER_AGENT=${PROFILER_AGENT_COMMAND}
fi

# Avoid adding Profiler twice for Alpha users
if [[ $JAVA_USER_OPTS = *"profiler_java_agent.so"* ]]; then
  echo "WARNING: Stackdriver Profiler seems to be enabled already using JAVA_USER_OPTS."
  PROFILER_AGENT=
fi