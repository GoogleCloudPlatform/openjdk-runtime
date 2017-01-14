package com.google.cloud.runtimes.monitoring.shutdown.config;

public class SysEnvironment {

  public SysEnvironment() {
  }

  public String get(String variable) {
    return System.getenv(variable);
  }
}
