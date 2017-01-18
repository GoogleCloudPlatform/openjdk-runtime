/*
 * Copyright 2017 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.cloud.runtimes.monitoring.shutdown.config;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class AgentConfigTest {

  private TestSysEnvironment testSysEnvironment = new TestSysEnvironment();
  private String heapInfoEnvVar = "SHUTDOWN_LOGGING_HEAP_INFO";
  private String threadDumpEnvVar = "SHUTDOWN_LOGGING_THREAD_DUMP";

  @Test
  public void agentParamsAreParsedCorrectly() {
    testSysEnvironment.clear(heapInfoEnvVar);
    testSysEnvironment.clear(threadDumpEnvVar);
    String params = "heap_info=true;thread_dump=false;timeout=20";
    AgentConfig agentConfig = new AgentConfig(params, testSysEnvironment);
    assertEquals(agentConfig.isHeapInfoEnabled(), true);
    assertEquals(agentConfig.isThreadDumpEnabled(), false);
    assertEquals(agentConfig.getTimeOutInSeconds(), 20);
    params = "heap_info=false;thread_dump=true";
    agentConfig = new AgentConfig(params, testSysEnvironment);
    assertEquals(agentConfig.isHeapInfoEnabled(), false);
    assertEquals(agentConfig.isThreadDumpEnabled(), true);
  }

  @Test
  public void defaultParamsAreUsedWhenNoParamsAreSpecified() {
    testSysEnvironment.clear(heapInfoEnvVar);
    testSysEnvironment.clear(threadDumpEnvVar);
    AgentConfig agentConfig = new AgentConfig(null, testSysEnvironment);
    assertEquals(agentConfig.isHeapInfoEnabled(), agentConfig.getHeapInfoDefault());
    assertEquals(agentConfig.isThreadDumpEnabled(), agentConfig.getThreadDumpDefault());
    assertEquals(agentConfig.getTimeOutInSeconds(), agentConfig.getTimeOutDefault());
  }

  @Test
  public void defaultTimeOutIsUsedIfTimeOutParameterIsNotInRange() {
    String params = "timeout=100";
    AgentConfig agentConfig = new AgentConfig(params, testSysEnvironment);
    assertEquals(agentConfig.getTimeOutInSeconds(), agentConfig.getTimeOutDefault());
    params = "timeout=-1";
    agentConfig = new AgentConfig(params, testSysEnvironment);
    assertEquals(agentConfig.getTimeOutInSeconds(), agentConfig.getTimeOutDefault());
    params = "timeout=25";
    agentConfig = new AgentConfig(params, testSysEnvironment);
    assertEquals(agentConfig.getTimeOutInSeconds(), 25);
  }

  @Test
  public void environmentVariablesOverrideDirectArguments() {
    testSysEnvironment.set(heapInfoEnvVar, "true");
    testSysEnvironment.set(threadDumpEnvVar, "false");
    String params = "heap_info=false;thread_dump=true";
    AgentConfig agentConfig = new AgentConfig(params, testSysEnvironment);
    assertEquals(agentConfig.isThreadDumpEnabled(), false);
    assertEquals(agentConfig.isHeapInfoEnabled(), true);
  }
}
