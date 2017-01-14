package com.google.cloud.runtimes.monitoring.shutdown.config;

import java.util.HashMap;
import java.util.Map;

public class TestSysEnvironment extends SysEnvironment {

  private Map<String, String> env;

  public TestSysEnvironment() {
    env = new HashMap<>();
  }

  /**
   * Test environment : set environment variable values.
   * @param prop Environment variable
   * @param value Value
   */
  public void set(String prop, String value) {
    env.put(prop, value);
  }

  /**
   * Test environment : remove environment variable.
   * @param prop Property name
   */
  public void clear(String prop) {
    if (env.containsKey(prop)) {
      env.remove(prop);
    }
  }

  @Override
  public String get(String prop) {
    return env.get(prop);
  }
}

