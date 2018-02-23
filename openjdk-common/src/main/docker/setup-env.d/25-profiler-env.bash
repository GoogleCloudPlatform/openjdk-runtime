#!/bin/bash

# configure Cloud Profiler

export PROFILER_AGENT_COMMAND=${PROFILER_AGENT_COMMAND:-"-agentpath:/opt/cprof/profiler_java_agent.so=--logtostderr"}

export PROFILER_AGENT=

if is_true "$PROFILER_ENABLE"; then
  PROFILER_AGENT=${PROFILER_AGENT_COMMAND}
fi
