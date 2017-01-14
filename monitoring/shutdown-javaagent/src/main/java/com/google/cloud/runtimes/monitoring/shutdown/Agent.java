package com.google.cloud.runtimes.monitoring.shutdown;

import com.google.cloud.runtimes.monitoring.shutdown.config.AgentConfig;
import com.google.cloud.runtimes.monitoring.shutdown.log.CloudLogging;
import com.google.cloud.runtimes.monitoring.shutdown.log.ILogging;

import java.lang.instrument.Instrumentation;
import java.security.AccessControlException;

public class Agent {

  public static volatile ShutdownReporter shutdownReporter;

  /**
   * Adds shutdown hook to java runtime to log heap info and stack trace.
   * Params
   * heap_info : true/false (default : true)
   * stack_trace : true/false (default : false)
   * time_out : integer (in seconds) (min : 1, max : 60, default : 30)
   * console : true/false (default : false, not intended to be enabled in production environment)
   */
  public static void premain(String agentArgs, Instrumentation instrumentation) {
    AgentConfig agentConfig = new AgentConfig(agentArgs);

    boolean isThreadDumpEnabled = agentConfig.isThreadDumpEnabled();

    boolean isHeapInfoEnabled = agentConfig.isHeapInfoEnabled();

    if (isThreadDumpEnabled || isHeapInfoEnabled) {
      int timeOutInSeconds = agentConfig.getTimeOutInSeconds();
      ILogging logging = new CloudLogging(agentConfig);
      try {
        shutdownReporter = new ShutdownReporter(isThreadDumpEnabled, isHeapInfoEnabled,
            timeOutInSeconds * 1000, logging);
        Runtime.getRuntime().addShutdownHook(shutdownReporter);
        logging.logImmediately(getShutdownHookAddedMessage(isThreadDumpEnabled, isHeapInfoEnabled,
            timeOutInSeconds));
      } catch (AccessControlException e) {
        logging.logImmediately("JVM Shutdownhook blocked :" + e.getMessage());
      }
    }
  }

  private static String getShutdownHookAddedMessage(boolean isThreadDumpEnabled,
      boolean isHeapInfoEnabled, int timeOutInSeconds) {
    return "JVM shutdown hook added. Thread dump : "
        + isThreadDumpEnabled + ", Heap info : " + isHeapInfoEnabled
        + ", Time out in seconds : " + timeOutInSeconds + "\n";
  }
}


