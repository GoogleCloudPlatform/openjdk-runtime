package com.google.cloud.runtimes.monitoring.shutdown.log;

public interface ILogging {

  void initialize();

  void log(String text);

  void flush();

  void logImmediately(String text);
}
