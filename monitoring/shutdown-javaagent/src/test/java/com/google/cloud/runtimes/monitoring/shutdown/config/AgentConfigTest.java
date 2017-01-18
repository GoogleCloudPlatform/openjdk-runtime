package com.google.cloud.runtimes.monitoring.shutdown.config;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class AgentConfigTest {

  private TestSysEnvironment testSysEnvironment = new TestSysEnvironment();
  private String heapInfoEnvVar = "SHUTDOWN_LOGGING_HEAP_INFO";
  private String threadDumpEnvVar = "SHUTDOWN_LOGGING_THREAD_DUMP";

  @Test
  public void paramsParsing() {
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
  public void defaultParams() {
    testSysEnvironment.clear(heapInfoEnvVar);
    testSysEnvironment.clear(threadDumpEnvVar);
    AgentConfig agentConfig = new AgentConfig(null, testSysEnvironment);
    assertEquals(agentConfig.isHeapInfoEnabled(), agentConfig.getHeapInfoDefault());
    assertEquals(agentConfig.isThreadDumpEnabled(), agentConfig.getThreadDumpDefault());
    assertEquals(agentConfig.getTimeOutInSeconds(), agentConfig.getTimeOutDefault());
  }

  @Test
  public void timeOutParamWithinRange() {
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
  public void envVarOverridesDirectArguments() {
    testSysEnvironment.set(heapInfoEnvVar, "true");
    testSysEnvironment.set(threadDumpEnvVar, "false");
    String params = "heap_info=false;thread_dump=true";
    AgentConfig agentConfig = new AgentConfig(params, testSysEnvironment);
    assertEquals(agentConfig.isThreadDumpEnabled(), false);
    assertEquals(agentConfig.isHeapInfoEnabled(), true);
  }
}