package com.google.cloud.runtimes.monitoring.shutdown.log;

public class TestLogging implements ILogging {

  private StringBuilder logBuffer;

  public TestLogging() {
    this.logBuffer = new StringBuilder();
  }

  @Override
  public void initialize() {
  }

  @Override
  public void log(String text) {
    this.logBuffer.append(text);
  }

  /**
   * Clear and return pre-existing log.
   * @return  log string
   */
  public String clear() {
    String log = logBuffer.toString();
    logBuffer.setLength(0);
    return log;
  }

  @Override
  public void flush() {
  }

  @Override
  public void logImmediately(String text) {
    this.logBuffer.setLength(0);
    this.logBuffer.append(text);
  }
}